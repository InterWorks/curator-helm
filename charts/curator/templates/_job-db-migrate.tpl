{{/*
The db-migrate Job, rendered once per hook by job-db-migrate-install.yaml and
job-db-migrate-upgrade.yaml. Call it with (dict "root" . "mode" "install"|"upgrade").
The two Jobs are identical except for the name, the hook, and the admin credentials:
only the install run gets WEBADMIN_USER / WEBADMIN_PASSWORD, so Winter seeds that
backend user on a fresh database instead of a random `admin` whose password lands in
the job log. Upgrades never see the credentials.
*/}}
{{- define "curator.dbMigrateJob" -}}
{{- $install := eq .mode "install" -}}
{{- with .root -}}
apiVersion: batch/v1
kind: Job
metadata:
  {{- /* The upgrade Job keeps the pre-split name, so the leftover hook Job from earlier
  chart versions is replaced by before-hook-creation instead of being orphaned. */}}
  name: "{{ .Release.Name }}-db-migrate{{ if $install }}-install{{ end }}"
  labels:
    app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
    app.kubernetes.io/instance: {{ .Release.Name | quote }}
    app.kubernetes.io/version: {{ .Chart.AppVersion }}
    helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
  annotations:
    "helm.sh/hook": {{ if $install }}pre-install{{ else }}pre-upgrade{{ end }}
    "helm.sh/hook-weight": "50"
spec:
  template:
    metadata:
      name: "{{ .Release.Name }}-db-migrate{{ if $install }}-install{{ end }}"
      labels:
        app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
        app.kubernetes.io/instance: {{ .Release.Name | quote }}
        helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      restartPolicy: Never
      serviceAccountName: {{ include "curator.serviceAccountName" . }}
      containers:
      - name: db-migrate
        image: "{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        volumeMounts:
        - name: framework
          mountPath: /var/www/html/storage/framework
        - name: logs
          mountPath: /var/www/html/storage/logs
        - name: temp
          mountPath: /var/www/html/storage/temp
        - name: cms
          mountPath: /var/www/html/storage/cms
        - name: data
          mountPath: /var/www/html/storage/app
        {{- if .Values.curator.config }}
        {{- range $key, $value := .Values.curator.config }}
        - name: config
          mountPath: /var/www/html/config/{{ $key }}.php
          subPath: {{ $key }}.php
        {{- end }}
        {{- end }}
        {{- with .Values.extraVolumeMounts }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
        command: [ "php", "artisan", "portal:migrate" ]
        env:
          {{- include "env.environment" . | nindent 10 }}
          {{- if $install }}
          {{- /* Read by Winter's seeder on a fresh database: it creates this superuser
          (email <user>@no-reply.interworks.com) and logs no password. The Secret comes
          from externalsecrets-admin.yaml, a pre-install hook at a lower weight. */}}
          - name: WEBADMIN_PASSWORD
            valueFrom:
              secretKeyRef:
                name: {{ .Release.Name }}-admin
                key: admin-password
          - name: WEBADMIN_USER
            valueFrom:
              secretKeyRef:
                name: {{ .Release.Name }}-admin
                key: admin-user
          {{- end }}
          {{- /* directHost, not host: DDL and admin writes go straight to the primary,
          bypassing MaxScale. Falls back to host when directHost is unset. */}}
          - name: DB_HOST
            value: {{ include "curator.dbDirectHost" . }}
          {{- range $key, $value := .Values.curator.env }}
          - name: "{{ $key }}"
            value: "{{ $value }}"
          {{- end }}
      volumes:
      - name: framework
        emptyDir:
      - name: logs
        emptyDir:
      - name: temp
        emptyDir:
      - name: cms
        emptyDir:
      {{ if (and .Values.persistence.enabled (not .Values.persistence.s3.enabled)) -}}
      - name: data
        persistentVolumeClaim:
          claimName: {{ printf "%s-%s" "data" .Release.Name }}
      {{- else -}}
      - name: data
        emptyDir:
      {{- end }}
      {{- if .Values.curator.config }}
      - name: config
        configMap:
          name: {{ include "curator.fullname" . }}-config
      {{- end }}
      {{- with .Values.extraVolumes }}
      {{- toYaml . | nindent 6 }}
      {{- end }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end }}
{{- end -}}
