{{- /* ------------------------------------------------------------------ */ -}}
{{- /* Variable computation — no output                                   */ -}}
{{- /* ------------------------------------------------------------------ */ -}}
{{- $sinkInput := "journal" -}}
{{- if or .lowercase_fields .rename_host_field -}}{{- $sinkInput = "combined_transform" -}}{{- end -}}
{{- $hostField := "host" -}}
{{- if .rename_host_field -}}{{- $hostField = .host_field_name -}}{{- end -}}
{{- $containerField := "CONTAINER_NAME" -}}
{{- if .lowercase_fields -}}{{- $containerField = "container_name" -}}{{- end -}}
{{- $streamFields := printf "%s,%s" $hostField $containerField -}}
{{- if .vl_stream_fields -}}{{- $streamFields = .vl_stream_fields -}}{{- end -}}
data_dir: /data

sources:
  journal:
    type: journald
    journal_directory: /var/log/journal

{{ if or .lowercase_fields .rename_host_field -}}
transforms:
  combined_transform:
    type: remap
    inputs: [journal]
    source: |
{{- if .lowercase_fields }}
      . = map_keys(., recursive: true) -> |key| { downcase(key) }
{{- end }}
{{- if .rename_host_field }}
      .{{ .host_field_name }} = del(.host)
{{- end }}
{{- end }}

sinks:
  output:
{{- if eq .sink_type "victorialogs" }}
    type: elasticsearch
    inputs: [{{ $sinkInput }}]
    endpoints:
      - "{{ .vl_endpoint }}"
{{- if .vl_auth_user }}
    auth:
      strategy: basic
      user: "{{ .vl_auth_user }}"
      password: "{{ .vl_auth_password }}"
{{- end }}
    api_version: auto
    compression: gzip
    healthcheck:
      enabled: false
    query:
      _msg_field: message
      _time_field: timestamp
      _stream_fields: {{ $streamFields }}
{{- if .vl_ignore_fields }}
      ignore_fields: {{ .vl_ignore_fields }}
{{- end }}
{{- end }}
