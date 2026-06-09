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
{{ if .Values.curator.cache.driver }}
- name: CACHE_DRIVER
  value: {{ .Values.curator.cache.driver }}
{{ end }}
{{ if .Values.curator.cache.host }}
- name: CACHE_HOST
  value: {{ .Values.curator.cache.host }}
{{ end }}
{{ if .Values.curator.cache.port }}
- name: CACHE_PORT
  value: {{ .Values.curator.cache.port }}
{{ end }}
{{ if .Values.curator.cache.prefix }}
- name: CACHE_PREFIX
  value: {{ .Values.curator.cache.prefix | default .Values.environment }}
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
{{ if .Values.curator.cms.filesystemsUploadsPath }}
- name: FILESYSTEM_UPLOADS_PATH
  value: {{ .Values.curator.cms.filesystemsUploadsPath }}
{{ end }}
{{ if .Values.curator.cms.filesystemsMediaPath }}
- name: FILESYSTEM_MEDIA_PATH
  value: {{ .Values.curator.cms.filesystemsMediaPath }}
{{ end }}
{{ if .Values.curator.cms.enableCSRF }}
- name: ENABLE_CSRF
  value: {{ .Values.curator.cms.enableCSRF }}
{{ end }}
# database.php
{{ if .Values.curator.database.connection }}
- name: DB_DATABASE
  value: {{ .Values.curator.database.connection}}
{{ else }}
{{ if .Values.curator.database.host }}
- name: DB_HOST
  value: {{ .Values.curator.database.host }}
{{ else }}
- name: DB_HOST
  value: {{ .Values.mariadbOperator.mariadbEndpoint | default .Values.mariadbOperator.mariaDbName }}
{{ end }}
{{ if .Values.curator.database.databaseName }}
- name: DB_DATABASE
  value: {{ .Values.curator.database.databaseName}}
{{ else }}
- name: DB_DATABASE
  value: {{ .Values.mariadbOperator.database.name | default .Values.environment }}
{{ end }}
{{ if .Values.curator.database.user }}
- name: DB_USERNAME
  value: {{ .Values.curator.database.username }}
{{ else }}
- name: DB_USERNAME
  value: {{ .Values.mariadbOperator.user.username | default "curator"}}
{{ end }}
{{ if and (.Values.curator.database.password.secretKeyRef.name .values.curator.database.password.secretKeyRef.key )}}
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
###
# FILESYSTEM_DRIVER is created above.
# TODO should that go here instead?
###
{{ if .Values.curator.filesystems.filesystemDriver }}
- name: FILESYSTEM_DRIVER
  value: {{ .Values.curator.filesystems.filesystemDriver }}
{{ end }}
{{ if .Values.curator.filesystems.awsBucket }}
- name: AWS_BUCKET
  value: {{ .Values.curator.filesystems.awsBucket }}
{{ end }}
###
# AWS_DEFAULT_REGION is passed in via the pod identity webhook
###
{{ if .Values.persistence.s3.enabled -}}
- name: S3_BUCKET
  value: {{ .Values.persistence.s3.bucket | default .Values.environment }}
- name: S3_REGION
  value: {{ .Values.persistence.s3.region | default .Values.environment }}
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
{{ if and (.Values.curator.mail.passwordSecretRef.name .Values.curator.mail.passwordSecretRef.key) }}
- name: MAIL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.curator.mail.passwordSecretRef.name }}
      key: {{ .Values.curator.mail.passwordSecretRef.name.key }}
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
{{ if .Values.curator.powerbi.powerBiTenant }}
- name: MAIL_FROM_NAME
  value: {{ .Values.curator.mail.powerBiTenant }}
{{ end }}
{{ if and (.Values.curator.powerbi.clientIdSecretRef.name .Values.curator.powerbi.clientIdSecretRef.key) }}
- name: POWER_BI_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.curator.powerbi.clientIdSecretRef.name }}
      key: {{ .Values.curator.powerbi.clientIdSecretRef.key }}
{{ end }}
{{ if and (.Values.curator.powerbi.clientSecretSecretRef.name .Values.curator.powerbi.clientSecretSecretRef.key) }}
- name: POWER_BI_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.curator.powerbi.clientSecretSecretRef.name }}
      key: {{ .Values.curator.powerbi.clientSecretSecretRef.key }}
{{ end }}
{{ if and (.Values.curator.powerbi.adminClientIdSecretRef.name .Values.curator.powerbi.adminClientIdSecretRef.key) }}
- name: POWER_BI_ADMIN_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.curator.powerbi.adminClientIdSecretRef.name }}
      key: {{ .Values.curator.powerbi.adminClientIdSecretRef.key }}
{{ end }}
{{ if and (.Values.curator.powerbi.adminClientSecretSecretRef.name .Values.curator.powerbi.adminClientSecretSecretRef.key) }}
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
{{ if .Values.curator.session.sessionDriver }}
- name: SESSION_DRIVER
  value: {{ .Values.curator.session.sessionDriver }}
{{ end }}
{{ if .Values.curator.session.sessionCookie }}
- name: SESSION_COOKIE
  value: {{ .Values.curator.session.sessionCookie }}
{{ end }}
{{ if .Values.curator.session.sessionSecureCookie }}
- name: SESSION_SECURE_COOKIE
  value: {{ .Values.curator.session.sessionSecureCookie }}
{{ end }}
# view.php
###
# No configurable items in view
###


{{- range .Values.curator.envFromSecret }}
- name: {{ .name }}
  valueFrom:
    secretKeyRef:
        name: {{ .key }}
        key: {{ .value }}
{{- end }}
{{ end }}