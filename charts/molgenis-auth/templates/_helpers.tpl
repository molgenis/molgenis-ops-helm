{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "molgenis-auth.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "molgenis-auth.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "molgenis-auth.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "molgenis-auth.labels" -}}
app.kubernetes.io/name: {{ include "molgenis-auth.name" . }}
helm.sh/chart: {{ include "molgenis-auth.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Resolve hostname for environment
*/}}
{{- define "molgenis-auth.hostname" -}}
{{- if ne (.Values.environment | default "prod" ) "prod" -}}
{{- printf "%s.%s.molgenis.org" .Release.Name .Values.environment -}}
{{- else -}}
{{- printf "%s.molgenis.org" .Release.Name -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "molgenis-auth.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "molgenis-auth.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
The name of the config.
*/}}
{{- define "molgenis-auth.configname" -}}
{{- if .Values.config.nameOverride -}}
{{ .Values.config.nameOverride }}
{{- else -}}
{{ include "molgenis-auth.fullname" . }}-config
{{- end -}}
{{- end -}}

{{/*
The name of the secret.
*/}}
{{- define "molgenis-auth.secretname" -}}
{{- if .Values.secret.nameOverride -}}
{{ .Values.secret.nameOverride }}
{{- else -}}
{{ include "molgenis-auth.fullname" . }}-secret
{{- end -}}
{{- end -}}