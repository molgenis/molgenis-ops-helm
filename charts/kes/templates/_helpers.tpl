{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "kes.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kes.fullname" -}}
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
{{- define "kes.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "kes.labels" -}}
app.kubernetes.io/name: {{ include "kes.name" . }}
helm.sh/chart: {{ include "kes.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "kes.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "kes.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Generate Self-signed TLS certificate
*/}}
{{- define "kes.gen-tls" -}}
{{- $altNames := list ( printf "%s.%s" (include "kes.name" .) .Release.Namespace ) ( printf "%s.%s.svc" (include "kes.name" .) .Release.Namespace ) -}}
{{- $ca := genCA "kes-ca" 365 -}}
{{- $cert := genSignedCert ( include "kes.name" . ) nil $altNames 365 $ca -}}
server.cert: {{ $cert.Cert | b64enc }}
server.key: {{ $cert.Key | b64enc }}
{{- end -}}