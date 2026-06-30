{{- define "flask-api.name" -}}
{{ .Chart.Name }}
{{- end }}

{{- define "flask-api.fullname" -}}
{{ .Release.Name }}
{{- end }}