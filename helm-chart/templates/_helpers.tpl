{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "summit-common-helm_chart-svc.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "summit-common-helm_chart-svc.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "summit-common-helm_chart-svc.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "summit-common-helm_chart-svc.labels" -}}
helm.sh/chart: {{ include "summit-common-helm_chart-svc.chart" . }}
{{ include "summit-common-helm_chart-svc.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "summit-common-helm_chart-svc.selectorLabels" -}}
app.kubernetes.io/name: {{ include "summit-common-helm_chart-svc.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use.
*/}}
{{- define "summit-common-helm_chart-svc.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "summit-common-helm_chart-svc.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Pod annotations
*/}}
{{- define "summit-common-helm_chart-svc.podAnnotations" -}}
{{- with .Values.podAnnotations }}
{{ toYaml . }}
{{- end }}
{{- if .Values.vault.enabled -}}
vault.hashicorp.com/agent-inject: {{ default true .Values.vault.inject | quote }}
vault.hashicorp.com/agent-inject-status: "update"
vault.hashicorp.com/agent-configmap: {{ include "summit-common-helm_chart-svc.fullname" . }}-vault-agent
{{- end }}
{{- end }}

{{/*
Create the name of the Vault role to use
*/}}
{{- define "summit-common-helm_chart-svc.vaultRole" -}}
{{- default (include "summit-common-helm_chart-svc.fullname" .) .Values.vault.role }}
{{- end }}

{{/*
Create the Vault secret path to use
*/}}
{{- define "summit-common-helm_chart-svc.vaultSecretPath" -}}
{{- default (printf "secret/%s" (include "summit-common-helm_chart-svc.fullname" .)) .Values.vault.secretPath }}
{{- end }}
