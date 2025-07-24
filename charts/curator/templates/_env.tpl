{{ define "env.environment" }}
- name: DB_HOST
  value: {{ .Values.mariadbOperator.mariaDbName | default "curator-mariadb" }}-primary
- name: DB_DATABASE
  value: {{ .Values.mariadbOperator.database.name | default .Values.environment }}
- name: DB_USERNAME
  value: {{ .Values.mariadbOperator.user.username | default "curator"}}
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.mariadbOperator.user.userPasswordSecretKeyRef.name | default (printf "%s-mariadb" .Values.environment) }}
      key: {{ .Values.mariadbOperator.user.userPasswordSecretKeyRef.key | default "password" }}
- name: CACHE_HOST
  value: "memcached"
- name: CACHE_PORT
  value: "11211"
- name: CACHE_PREFIX
  value: {{ .Values.curator.cache.prefix | default .Values.environment }}
{{ with (first .Values.ingress.hosts) -}}
- name: APP_URL
  value: {{ .host }}
{{ end -}}
{{ if .Values.persistence.s3.enabled -}}
- name: S3_BUCKET
  value: {{ .Values.persistence.s3.bucket | default .Values.environment }}
- name: S3_REGION
  value: {{ .Values.persistence.s3.region | default .Values.environment }}
{{- end }}
{{ end }}