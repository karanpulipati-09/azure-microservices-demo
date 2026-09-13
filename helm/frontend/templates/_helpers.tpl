{{- define "frontend.serviceAccountName" -}}
{{- default "frontend-sa" .Values.serviceAccount.name -}}
{{- end -}}
