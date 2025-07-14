{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "enrichment.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "enrichment.fullname" -}}
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
{{- define "enrichment.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Get KubeVersion removing pre-release information.
TODO: .Capabilities.KubeVersion.GitVersion is deprecated in Helm 3, switch to .Capabilities.KubeVersion.Version after migration.
*/}}
{{- define "service.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.GitVersion (regexFind "v[0-9]+\\.[0-9]+\\.[0-9]+" .Capabilities.KubeVersion.GitVersion ) -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "ingress.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "networking.k8s.io/v1") (semverCompare ">= 1.19.x" (include "service.kubeVersion" .)) -}}
      {{- print "networking.k8s.io/v1" -}}
  {{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" -}}
    {{- print "networking.k8s.io/v1beta1" -}}
  {{- else -}}
    {{- print "extensions/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
Return if ingress is stable.
*/}}
{{- define "ingress.isStable" -}}
  {{- eq (include "ingress.apiVersion" .) "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Return if ingress supports ingressClassName.
*/}}
{{- define "ingress.supportsIngressClassName" -}}
  {{- or (eq (include "ingress.isStable" .) "true") (and (eq (include "ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18.x" (include "service.kubeVersion" .))) -}}
{{- end -}}

{{/*
Return if ingress supports pathType.
*/}}
{{- define "ingress.supportsPathType" -}}
  {{- or (eq (include "ingress.isStable" .) "true") (and (eq (include "ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18.x" (include "service.kubeVersion" .))) -}}
{{- end -}}

{{/* Get Azure Deployment ID */}}
{{- define "enrichment.azureDeploymentId" -}}
{{- $azureModels := .Values.appConfig.genAI.llmProviders.models.azure }}
{{- if and $azureModels (gt (len $azureModels) 0) }}
{{- (index $azureModels 0).model }}
{{- else }}
{{- print "value not set" }}
{{- end }}
{{- end }}

{{/* Get Azure Resource Name */}}
{{- define "enrichment.azureResourceName" -}}
{{- $azureModels := .Values.appConfig.genAI.llmProviders.models.azure }}
{{- if and $azureModels (gt (len $azureModels) 0) }}
{{- (index $azureModels 0).resource_name }}
{{- else }}
{{- print "value not set" }}
{{- end }}
{{- end }}

{{/* Get Embeddings Model Name */}}
{{- define "enrichment.embeddingsModel" -}}
{{- $embeddingsModel := .Values.appConfig.genAI.llmProviders.embeddingsModel }}
{{- if $embeddingsModel }}
    {{- print $embeddingsModel }}
{{- else }}
    {{- print "value not set" }}  # Fallback to default if not set
{{- end }}
{{- end }}

{{/* Get provider type based on llmProviders.type */}}
{{- define "enrichment.providerType" -}}
{{- if eq .Values.appConfig.genAI.llmProviders.type "custom" -}}
{{- printf "%d" -1 -}}
{{- else if eq .Values.appConfig.genAI.llmProviders.type "openai" -}}
{{- printf "%d" 1 -}}
{{- else if eq .Values.appConfig.genAI.llmProviders.type "azure" -}}
{{- printf "%d" 2 -}}
{{- else -}}
{{- printf "%d" 0 -}}
{{- end -}}
{{- end -}}

{{/* Get Domain URL based on provider type */}}
{{- define "enrichment.llmDomainUrl" -}}
{{- if .Values.appConfig.genAI.customDomain }}
{{- .Values.appConfig.genAI.customDomain }}
{{- else if eq .Values.appConfig.genAI.llmProviders.type "custom" }}
{{- printf "http://%s-litellm:%v" (include "enrichment.fullname" .) .Values.litellm.service.port }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/* Get default model */}}
{{- define "enrichment.defaultModel" -}}
{{- if eq .Values.appConfig.genAI.llmProviders.type "custom" }}
{{- .Values.appConfig.genAI.llmProviders.defaultModel }}
{{- else }}
{{- $defaultModel := .Values.appConfig.genAI.llmProviders.defaultModel }}
{{- $allModels := dict }}
{{- range .Values.appConfig.genAI.llmProviders.models.openai }}
{{- $_ := set $allModels .name .model }}
{{- end }}
{{- range .Values.appConfig.genAI.llmProviders.models.azure }}
{{- $_ := set $allModels .name .model }}
{{- end }}
{{- range .Values.appConfig.genAI.llmProviders.models.bedrock }}
{{- $_ := set $allModels .name .model }}
{{- end }}
{{- get $allModels $defaultModel }}
{{- end }}
{{- end }}

{{/* Get OpenAI API Key */}}
{{- define "enrichment.openAIApiKey" -}}
{{- if eq .Values.appConfig.genAI.llmProviders.type "custom" }}
{{- $customApiKey := .Values.litellm.custom_api_key }}
{{- if not $customApiKey }}
{{- $randomStr := randAlphaNum 15 | lower }}
{{- printf "sk-%s" $randomStr }}
{{- else }}
{{- $customApiKey }}
{{- end }}
{{- else }}
{{- $defaultModel := .Values.appConfig.genAI.llmProviders.defaultModel }}
{{- $allModels := dict }}
{{- range .Values.appConfig.genAI.llmProviders.models.openai }}
{{- $_ := set $allModels .name (dict "model" .model "api_key" .api_key) }}
{{- end }}
{{- range .Values.appConfig.genAI.llmProviders.models.azure }}
{{- $_ := set $allModels .name (dict "model" .model "api_key" .api_key) }}
{{- end }}
{{- range .Values.appConfig.genAI.llmProviders.models.bedrock }}
{{- $_ := set $allModels .name (dict "model" .model "api_key" .aws_access_key_id) }}
{{- end }}
{{- if hasKey $allModels $defaultModel }}
{{- (get $allModels $defaultModel).api_key }}
{{- else }}
{{- print "value not set" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "jaeger.otel.endpoint" -}}
{{- printf "http://%s-jaeger:4317" (include "enrichment.fullname" .) }}
{{- end }}
