{{ define "env.environment" }}
# app.php
{{ if not (kindIs "invalid" .Values.curator.app.debug) }}
- name: APP_DEBUG
  value: {{ .Values.curator.app.debug | quote }}
{{ end }}
{{ with (first .Values.ingress.hosts) -}}
- name: APP_URL
  value: {{ .host }}
{{ end -}}
# TODO account for old value location
{{ if and .Values.curator.app.appKeySecret.name .Values.curator.app.appKeySecret.key }}
- name: APP_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.curator.app.appKeySecret.name | default (printf "%s-admin" .Release.Name) }}
      key: {{ .Values.curator.app.appKeySecret.key | default "app-key"}}
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
{{ if not (kindIs "invalid" .Values.curator.cms.routesCache) }}
- name: ROUTES_CACHE
  value: {{ .Values.curator.cms.routesCache | quote }}
{{ end }}
{{ if not (kindIs "invalid" .Values.curator.cms.assetCache) }}
- name: ASSET_CACHE
  value: {{ .Values.curator.cms.assetCache | quote }}
{{ end }}
{{ if not (kindIs "invalid" .Values.curator.cms.assetMinify) }}
- name: ASSET_MINIFY
  value: {{ .Values.curator.cms.assetMinify | quote }}
{{ end }}
- name: FILESYSTEM_DRIVER
  value: {{ .Values.curator.cms.filesystemDriver | default (ternary "s3" "local" .Values.persistence.s3.enabled) }}
{{ if .Values.curator.cms.filesystemUploadsPath }}
- name: FILESYSTEM_UPLOADS_PATH
  value: {{ .Values.curator.cms.filesystemUploadsPath }}
{{ else if .Values.persistence.s3.enabled }}
- name: FILESYSTEM_UPLOADS_PATH
  value: {{  (printf "https://%s.s3.amazonaws.com/uploads" .Values.persistence.s3.bucket) }}
{{ end }}
{{ if .Values.curator.cms.filesystemMediaPath }}
- name: FILESYSTEM_MEDIA_PATH
  value: {{ .Values.curator.cms.filesystemMediaPath }}
{{ else if .Values.persistence.s3.enabled }}
- name: FILESYSTEM_MEDIA_PATH
  value: {{ (printf "https://%s.s3.amazonaws.com/media" .Values.persistence.s3.bucket) }}
{{ end }}
{{ if not (kindIs "invalid" .Values.curator.cms.enableCSRF) }}
- name: ENABLE_CSRF
  value: {{ .Values.curator.cms.enableCSRF | quote }}
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
{{ if .Values.curator.database.port }}
- name: DB_PORT
  value: {{ .Values.curator.database.port | quote }}
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
{{ if and .Values.persistence.s3.accessKeyIdSecret.name .Values.persistence.s3.accessKeyIdSecret.key }}
- name: AWS_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.persistence.s3.accessKeyIdSecret.name }}
      key: {{ .Values.persistence.s3.accessKeyIdSecret.key }}
{{ end }}
{{ if and .Values.persistence.s3.secretAccessKeySecret.name .Values.persistence.s3.secretAccessKeySecret.key }}
- name: AWS_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.persistence.s3.secretAccessKeySecret.name }}
      key: {{ .Values.persistence.s3.secretAccessKeySecret.key }}
{{ end }}
{{- end }}
# logging.php
- name: LOG_CHANNEL
  value: {{ .Values.curator.logging.channel | default "stdout" | quote }}
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
  value: {{ .Values.curator.mail.port | quote }}
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
{{ if not (kindIs "invalid" .Values.curator.powerbi.cacheEnabled) }}
- name: POWER_BI_CACHE_ENABLED
  value: {{ .Values.curator.powerbi.cacheEnabled | quote }}
{{ end }}
{{ if .Values.curator.powerbi.cacheExpirySeconds }}
- name: POWER_BI_CACHE_EXPIRY_SECONDS
  value: {{ .Values.curator.powerbi.cacheExpirySeconds | quote }}
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
# winter/search/search.php
{{ if .Values.curator.search.driver }}
{{ $validSearchEngine := list "database" "typesense" "" }}
{{ if not (has .Values.curator.search.driver $validSearchEngine )}}
{{ fail (printf "Invalid search driver '%s'. Must be either 'database', 'typesense', or unset" .Values.curator.search.driver) }}
{{ end }}
{{ end }}
{{- if .Values.curator.search.driver }}
- name: SEARCH_DRIVER
  value: {{ .Values.curator.search.driver }}
{{- end }}
{{- if .Values.curator.search.prefix }}
- name: SEARCH_PREFIX
  value: {{ .Values.curator.search.prefix }}
{{- end }}
{{- if .Values.curator.search.queue }}
- name: SEARCH_QUEUE
  value: {{ .Values.curator.search.queue }}
{{- end }}
# Config for algolia driver
{{ if and (eq .Values.curator.search.driver "algolia") }}
{{- if .Values.curator.search.algolia.identify }}
- name: SEARCH_IDENTIFY
  value: {{ .Values.curator.search.algolia.identify }}
{{- end }}
{{- if and .Values.curator.search.algolia.idSecretRef.name .Values.curator.search.algolia.idSecretRef.key}}
{{ with .Values.curator.search.algolia.idSecretRef }}
- name: ALGOLIA_APP_ID
  valueFrom:
    secretKeyRef:
        name: {{ .name }}
        key: {{ .key }}
{{ end }}
{{- end }}
{{- if and .Values.curator.search.algolia.secretValueSecretRef.name .Values.curator.search.algolia.secretValueSecretRef.key}}
{{ with .Values.curator.search.algolia.secretValueSecretRef }}
- name: ALGOLIA_APP_SECRET
  valueFrom:
    secretKeyRef:
        name: {{ .name }}
        key: {{ .key }}
{{ end }}
{{- end }}
{{- end }}
# end config for algolia driver
# config for typesearch driver
{{ if eq .Values.curator.search.driver "typesense" }}
{{- if and .Values.curator.search.typesense.apiKeySecretRef.name .Values.curator.search.typesense.apiKeySecretRef.key}}
{{ with .Values.curator.search.typesense.apiKeySecretRef }}
- name: TYPESENSE_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .name }}
      key: {{ .key }}
{{- end }}
{{- end }}
{{- if .Values.curator.search.typesense.host }}
- name: TYPESENSE_HOST
  value: {{ .Values.curator.search.typesense.host }}
{{- end }}
{{- if .Values.curator.search.typesense.port }}
- name: TYPESENSE_PORT
  value: {{ .Values.curator.search.typesense.port | quote }}
{{- end }}
{{- if .Values.curator.search.typesense.path }}
- name: TYPESENSE_PATH
  value: {{ .Values.curator.search.typesense.path }}
{{- end }}
{{- if .Values.curator.search.typesense.protocol }}
- name: TYPESENSE_PROTOCOL
  value: {{ .Values.curator.search.typesense.protocol }}
{{- end }}
{{- if .Values.curator.search.typesense.connection.timeout }}
- name: TYPESENSE_CONNECTION_TIMEOUT_SECONDS
  value: {{ .Values.curator.search.typesense.connection.timeout | quote }}
{{- end }}
{{- if .Values.curator.search.typesense.connection.healthcheckInterval }}
- name: TYPESENSE_HEALTHCHECK_INTERVAL_SECONDS
  value: {{ .Values.curator.search.typesense.connection.healthcheckInterval | quote }}
{{- end }}
{{- if .Values.curator.search.typesense.connection.retries }}
- name: TYPESENSE_NUM_RETRIES
  value: {{ .Values.curator.search.typesense.connection.retries | quote }}
{{- end }}
{{- if .Values.curator.search.typesense.connection.retryInterval }}
- name: TYPESENSE_RETRY_INTERVAL_SECONDS
  value: {{ .Values.curator.search.typesense.connection.retryInterval | quote }}
{{- end }}
{{- if .Values.curator.search.typesense.maxResults }}
- name: TYPESENSE_MAX_RESULTS
  value: {{ .Values.curator.search.typesense.maxResults | quote}}
{{- end }}
{{- if .Values.curator.search.typesense.importAction }}
- name: TYPESENSE_IMPORT_ACTION
  value: {{ .Values.curator.search.typesense.importAction }}
{{- end }}
{{ end }}
# end typesense config
# session.php
- name: SESSION_DRIVER
  value: {{ .Values.curator.session.driver | default "database" | quote }}
{{ if .Values.curator.session.cookie }}
- name: SESSION_COOKIE
  value: {{ .Values.curator.session.cookie }}
{{ end }}
{{ if not (kindIs "invalid" .Values.curator.session.secureCookie) }}
- name: SESSION_SECURE_COOKIE
  value: {{ .Values.curator.session.secureCookie | quote }}
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