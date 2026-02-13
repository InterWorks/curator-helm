{{ define "env.environment" }}
# app.php
{{ if .Values.curator.app.debug }}
- name: APP_DEBUG
  value: {{ .Values.curator.app.debug }}
{{ end }}
{{ with (first .Values.ingress.hosts) -}}
- name: APP_URL
  value: {{ .host }}
{{ end -}}
# TODO account for old value location
- name: APP_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.curator.app.appKeySecret.name | default (printf "%s-admin" .Release.Name) }}
      value: {{ .Values.curator.app.appKeySecret.key | default "app-key"}}
# cache.php
- name: CACHE_DRIVER
  value: {{ .Values.curator.cache.type | default "memcached" }}
- name: CACHE_HOST
  value: {{ .Values.curator.cache.host | default "memcached"}}
- name: CACHE_PORT
  value: {{ .Values.curator.cache.port | default "11211" }}
- name: CACHE_PREFIX
  value: {{ .Values.curator.cache.prefix | default .Values.environment }}
# cms.php
- name: ROUTES_CACHE
  value: {{ .Values.curator.cms.routesCache | default true }}
- name: ASSET_CACHE
  value: {{ .Values.curator.cms.assetCache | default true }}
- name: ASSET_MINIFY
  value: {{ .Values.curator.cms.assetMinify | default true }}
- name: FILESYSTEM_DRIVER
  value: {{ .Values.curator.cms.filesystemDriver | default "s3" }}
- name: FILESYSTEM_UPLOADS_PATH
  value: {{ .Values.curator.cms.uploadsPath | default "s3" }}
- name: FILESYSTEM_MEDIA_PATH
  value: {{ .Values.curator.cms.mediaPath | default "s3" }}
- name: ENABLE_CSRF
  value: {{ .Values.curator.cms.enableCSRF | default true }}
# database.php
- name: DB_HOST
  value: {{ .Values.mariadbOperator.mariadbEndpoint | default .Values.mariadbOperator.mariaDbName }}
- name: DB_DATABASE
  value: {{ .Values.mariadbOperator.database.name | default .Values.environment }}
- name: DB_USERNAME
  value: {{ .Values.mariadbOperator.user.username | default "curator"}}
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.mariadbOperator.user.userPasswordSecretKeyRef.name | default (printf "%s-mariadb" .Values.environment) }}
      key: {{ .Values.mariadbOperator.user.userPasswordSecretKeyRef.key | default "password" }}
{{ if .Values.persistence.s3.enabled -}}
- name: S3_BUCKET
  value: {{ .Values.persistence.s3.bucket | default .Values.environment }}
- name: S3_REGION
  value: {{ .Values.persistence.s3.region | default .Values.environment }}
{{- end }}
{{- range .Values.curator.envFromSecret }}
- name: {{ .name }}
  valueFrom:
    secretKeyRef:
        name: {{ .key }}
        key: {{ .value }}
{{- end }}
{{ end }}