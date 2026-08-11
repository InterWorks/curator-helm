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
{{ if .Values.curator.app.appKeySecret }}
- name: APP_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.curator.app.appKeySecret.name | default (printf "%s-admin" .Release.Name) }}
      value: {{ .Values.curator.app.appKeySecret.key | default "app-key"}}
{{ end }}
# cache.php
- name: CACHE_DRIVER
  value: {{ .Values.curator.cache.driver | default "memcached" }}
- name: MEMCACHED_HOST
  value: {{ .Values.curator.cache.host | default "memcached" }}
- name: MEMCACHED_PORT
  value: {{ .Values.curator.cache.port | default "11211" | quote }}
{{ if .Values.curator.cache.prefix }}
- name: CACHE_PREFIX
  value: {{ .Values.curator.cache.prefix }}
{{ end }}
# cms.php
{{ if .Values.curator.cms.routesCache }}
- name: ROUTES_CACHE
  value: {{ .Values.curator.cms.routesCache }}
{{ end }}
{{ if .Values.curator.cms.assetCache }}
- name: ASSET_CACHE
  value: {{ .Values.curator.cms.assetCache }}
{{ end }}
{{ if .Values.curator.cms.assetMinify }}
- name: ASSET_MINIFY
  value: {{ .Values.curator.cms.assetMinify }}
{{ end }}
- name: FILESYSTEM_DRIVER
  value: {{ .Values.curator.cms.filesystemDriver | default (ternary "s3" "local" .Values.persistence.s3.enabled) }}
{{ if .Values.curator.cms.filesystemUploadsPath }}
- name: FILESYSTEM_UPLOADS_PATH
  value: {{ .Values.curator.cms.filesystemUploadsPath }}
{{ end }}
{{ if .Values.curator.cms.filesystemMediaPath }}
- name: FILESYSTEM_MEDIA_PATH
  value: {{ .Values.curator.cms.filesystemMediaPath }}
{{ end }}
{{ if .Values.curator.cms.enableCSRF }}
- name: ENABLE_CSRF
  value: {{ .Values.curator.cms.enableCSRF }}
{{ end }}
# database.php
{{ if .Values.curator.database.connection }}
- name: DB_CONNECTION
  value: {{ .Values.curator.database.connection }}
{{ end }}
{{ if .Values.curator.database.databaseName }}
- name: DB_DATABASE
  value: {{ .Values.curator.database.databaseName}}
{{ else }}
- name: DB_DATABASE
  value: {{ .Values.mariadbOperator.database.name | default .Values.environment }}
{{ end }}
{{ if .Values.curator.database.username }}
- name: DB_USERNAME
  value: {{ .Values.curator.database.username }}
{{ else }}
- name: DB_USERNAME
  value: {{ .Values.mariadbOperator.user.username | default "curator"}}
{{ end }}
{{ if and .Values.curator.database.password.secretKeyRef.name .Values.curator.database.password.secretKeyRef.key }}
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.curator.database.password.secretKeyRef.name }}
      key: {{ .Values.curator.database.password.secretKeyRef.key }}
{{ else }}
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.mariadbOperator.user.userPasswordSecretKeyRef.name | default (printf "%s-mariadb" .Values.environment) }}
      key: {{ .Values.mariadbOperator.user.userPasswordSecretKeyRef.key | default "password" }}
{{ end }}
# filesystems.php
- name: FILESYSTEM_DISK
  value: {{ .Values.curator.filesystems.disk | default (ternary "s3" "local" .Values.persistence.s3.enabled) }}
{{ if .Values.persistence.s3.enabled -}}
- name: AWS_BUCKET
  value: {{ .Values.persistence.s3.bucket }}
{{ if .Values.persistence.s3.region }}
- name: AWS_DEFAULT_REGION
  value: {{ .Values.persistence.s3.region }}
{{ end }}
{{ if .Values.persistence.s3.endpoint }}
- name: AWS_ENDPOINT
  value: {{ .Values.persistence.s3.endpoint }}
{{ end }}
{{ if .Values.persistence.s3.accessKeyIdSecret }}
- name: AWS_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.persistence.s3.accessKeyIdSecret.name }}
      key: {{ .Values.persistence.s3.accessKeyIdSecret.key }}
{{ end }}
{{ if .Values.persistence.s3.secretAccessKeySecret }}
- name: AWS_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.persistence.s3.secretAccessKeySecret.name }}
      key: {{ .Values.persistence.s3.secretAccessKeySecret.key }}
{{ end }}
{{- end }}
# logging.php
{{ if .Values.curator.logging.channel }}
- name: LOG_CHANNEL
  value: {{ .Values.curator.logging.channel }}
{{ end }}
{{ if .Values.curator.logging.deprecationsChannel }}
- name: LOG_DEPRECATIONS_CHANNEL
  value: {{ .Values.curator.logging.deprecationsChannel }}
{{ end }}
{{ if .Values.curator.logging.level }}
- name: LOG_LEVEL
  value: {{ .Values.curator.logging.level }}
{{ end }}
# mail.php
{{ if .Values.curator.mail.host }}
- name: MAIL_HOST
  value: {{ .Values.curator.mail.host }}
{{ end }}
{{ if and .Values.curator.mail.passwordSecretRef.name .Values.curator.mail.passwordSecretRef.key }}
- name: MAIL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.curator.mail.passwordSecretRef.name }}
      key: {{ .Values.curator.mail.passwordSecretRef.key }}
{{ end }}
{{ if .Values.curator.mail.port }}
- name: MAIL_PORT
  value: {{ .Values.curator.mail.port }}
{{ end }}
{{ if .Values.curator.mail.username }}
- name: MAIL_USERNAME
  value: {{ .Values.curator.mail.username }}
{{ end }}
{{ if .Values.curator.mail.fromAddress }}
- name: MAIL_FROM_ADDRESS
  value: {{ .Values.curator.mail.fromAddress }}
{{ end }}
{{ if .Values.curator.mail.fromName }}
- name: MAIL_FROM_NAME
  value: {{ .Values.curator.mail.fromName }}
{{ end }}
{{ if .Values.curator.mail.ehloDomain }}
- name: MAIL_EHLO_DOMAIN
  value: {{ .Values.curator.mail.ehloDomain }}
{{ end }}
# powerbi.php
{{ if .Values.curator.powerbi.tenant }}
- name: POWER_BI_TENANT
  value: {{ .Values.curator.powerbi.tenant }}
{{ end }}
{{ if and .Values.curator.powerbi.clientIdSecretRef.name .Values.curator.powerbi.clientIdSecretRef.key }}
- name: POWER_BI_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.curator.powerbi.clientIdSecretRef.name }}
      key: {{ .Values.curator.powerbi.clientIdSecretRef.key }}
{{ end }}
{{ if and .Values.curator.powerbi.clientSecretSecretRef.name .Values.curator.powerbi.clientSecretSecretRef.key }}
- name: POWER_BI_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.curator.powerbi.clientSecretSecretRef.name }}
      key: {{ .Values.curator.powerbi.clientSecretSecretRef.key }}
{{ end }}
{{ if and .Values.curator.powerbi.adminClientIdSecretRef.name .Values.curator.powerbi.adminClientIdSecretRef.key }}
- name: POWER_BI_ADMIN_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.curator.powerbi.adminClientIdSecretRef.name }}
      key: {{ .Values.curator.powerbi.adminClientIdSecretRef.key }}
{{ end }}
{{ if and .Values.curator.powerbi.adminClientSecretSecretRef.name .Values.curator.powerbi.adminClientSecretSecretRef.key }}
- name: POWER_BI_ADMIN_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.curator.powerbi.adminClientSecretSecretRef.name }}
      key: {{ .Values.curator.powerbi.adminClientSecretSecretRef.key }}
{{ end }}
{{ if .Values.curator.powerbi.redirectURI }}
- name: POWER_BI_REDIRECT_URI
  value: {{ .Values.curator.powerbi.redirectURI }}
{{ end }}
{{ if .Values.curator.powerbi.cacheEnabled }}
- name: POWER_BI_CACHE_ENABLED
  value: {{ .Values.curator.powerbi.cacheEnabled }}
{{ end }}
{{ if .Values.curator.powerbi.cacheExpirySeconds }}
- name: POWER_BI_CACHE_EXPIRY_SECONDS
  value: {{ .Values.curator.powerbi.cacheExpirySeconds }}
{{ end }}
# queue.php
{{ if .Values.curator.queue.connection }}
- name: QUEUE_CONNECTION
  value: {{ .Values.curator.queue.connection }}
{{ end }}
# services.php
###
# No configurable items in services
###
# session.php
{{ if .Values.curator.session.driver }}
- name: SESSION_DRIVER
  value: {{ .Values.curator.session.driver }}
{{ end }}
{{ if .Values.curator.session.cookie }}
- name: SESSION_COOKIE
  value: {{ .Values.curator.session.cookie }}
{{ end }}
{{ if .Values.curator.session.secureCookie }}
- name: SESSION_SECURE_COOKIE
  value: {{ .Values.curator.session.secureCookie }}
{{ end }}
# view.php
###
# No configurable items in view
###
{{- if .Values.curator.sentry.dsn }}
- name: SENTRY_LARAVEL_DSN
  value: {{ .Values.curator.sentry.dsn }}
{{- end }}
- name: SENTRY_ENVIRONMENT
  value: {{ .Values.curator.sentry.environment | default .Release.Name }}
{{- range .Values.curator.envFromSecret }}
- name: {{ .name }}
  valueFrom:
    secretKeyRef:
        name: {{ .key }}
        key: {{ .value }}
{{- end }}
{{- end -}}