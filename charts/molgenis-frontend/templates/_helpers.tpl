{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "frontend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "frontend.fullname" -}}
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
{{- define "frontend.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Resolve hostname for environment
*/}}
{{- define "hostname" -}}
{{- if ne (.Values.environment | default "prod" ) "prod" -}}
{{- printf "%s.%s.molgenis.org" .Release.Name .Values.environment -}}
{{- else -}}
{{- printf "%s.molgenis.org" .Release.Name -}}
{{- end -}}
{{- end -}}

{{/*
Resolve hostname for environment
*/}}
{{- define "backend.servicename" -}}
{{- if .Values.proxy.backend.service.enabled -}}
{{- if and .Values.proxy.backend.service.targetRelease .Values.proxy.backend.service.targetNamespace -}}
{{- printf "http://%s.%s-molgenis.svc:8080" .Values.proxy.backend.service.targetRelease .Values.proxy.backend.service.targetNamespace -}}
{{- else -}}
{{- printf "http://%s-molgenis.svc:8080" .Release.Name -}}
{{- end -}}
{{- else -}}
{{- printf "%s" .Values.proxy.backend.url -}}
{{- end -}}
{{- end -}}