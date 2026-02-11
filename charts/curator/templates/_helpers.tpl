{{/*
Expand the name of the chart.
*/}}
{{- define "curator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "curator.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "curator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "curator.labels" -}}
helm.sh/chart: {{ include "curator.chart" . }}
{{ include "curator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "curator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "curator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "curator.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default ( .Release.Name) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "curator.mariadb.fullname" -}}
{{- if .Values.mariadb.externalHost -}}
{{- .Values.mariadb.externalHost -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name "mariadb" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{/*
Create a default fully qualified app name for php because single quotes are required
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "curator.mariadb.phpname" -}}
{{- if .Values.mariadb.externalHost -}}
{{- .Values.mariadb.externalHost -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name "mariadb" | trunc 63 | trimSuffix "-" | squote -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "curator.memcached.fullname" -}}
{{- printf "%s-%s" .Release.Name "memcached" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name for php because single quotes are required
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "curator.memcached.phpname" -}}
{{- printf "%s-%s" .Release.Name "memcached" | trunc 63 | trimSuffix "-" | squote -}}
{{- end -}}

{{/*
Storage Class
*/}}
{{- define "curator.persistence.storageClass" -}}
{{- $storageClass := .Values.global.storageClass | default .Values.persistence.storageClass }}
{{- if $storageClass }}
storageClassName: {{ $storageClass | quote }}
{{- end }}
{{- end -}}

{{/*
Create the resource blocks based on environment sizing or allow for overrides
*/}}
{{- define "curator.resources" -}}
{{- if .Values.resources -}}
{{- toYaml .Values.resources | nindent 4 -}}
{{- else -}}
{{- if eq .Values.environment "production" -}}
requests:
  cpu: 1
  memory: 1Gi
limits:
  cpu: 1500m
  memory: 2Gi
{{- else -}}
requests:
  cpu: 500m
  memory: 512Mi
limits:
  cpu: 500m
  memory: 512Mi
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create the admin secret name based on environment and optional siteIdentifier
*/}}
{{- define "curator.adminSecretName" -}}
{{- .Values.environment }}{{- if .Values.siteIdentifier }}-{{ .Values.siteIdentifier }}{{- end }}-admin
{{- end -}}