{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "molgenis.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "molgenis.fullname" -}}
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
{{- define "molgenis.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Resolve hostname for environment
*/}}
{{- define "molgenis.hostname" -}}
{{- if ne (.Values.molgenis.environment | default "prod" ) "prod" -}}
{{- printf "%s.%s.molgenis.org" .Release.Name .Values.molgenis.environment -}}
{{- else -}}
{{- printf "%s.molgenis.org" .Release.Name -}}
{{- end -}}
{{- end -}}

{{/*
Resolve Java OPTS for memory settings MOLGENIS
*/}}
{{- define "molgenis.javaOpts" -}}
{{- if eq .Values.molgenis.type.kind "large" -}}
{{- printf "-Xmx%s -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled" .Values.molgenis.type.large.javaOpts.maxHeapSpace -}}
{{- else if eq .Values.molgenis.type.kind "medium" -}}
{{- printf "-Xmx%s -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled" .Values.molgenis.type.medium.javaOpts.maxHeapSpace -}}
{{- else -}}
{{- printf "-Xmx%s -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled" .Values.molgenis.type.small.javaOpts.maxHeapSpace -}}
{{- end -}}
{{- end -}}

{{/*
Resolve storage size MOLGENIS
*/}}
{{- define "molgenis.storage.size" -}}
{{- if eq .Values.molgenis.type.kind "large" -}}
{{- printf "%s" .Values.molgenis.type.small.persistence.size }}
{{- else if eq .Values.molgenis.type.kind "medium" }}
{{- printf "%s" .Values.molgenis.type.medium.persistence.size }}
{{- else }}
{{- printf "%s" .Values.molgenis.type.large.persistence.size }}
{{- end }}
{{- end }}

{{/*
Resolve storage size MOLGENIS
*/}}
{{- define "molgenis.resources" -}}
{{- if eq .Values.molgenis.type.kind "small" }}
{{ toYaml .Values.molgenis.type.small.resources | indent 12 }}
{{- else if eq .Values.molgenis.type.kind "medium" }}
{{ toYaml .Values.molgenis.type.medium.resources | indent 12 }}
{{- else }}
{{ toYaml .Values.molgenis.type.large.resources | indent 12 }}
{{- end }}
{{- end }}


