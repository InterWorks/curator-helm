{{- define "curator.checkImageTag" -}}

{{- $minVersion := "2025.5.1" }}

{{- $tag := .Values.image.tag | default "" | trim }}
{{- $override := .Values.image.tagOverride | default "" | trim }}

{{- if not $tag }}
  {{- fail "ERROR: image.tag is not set." }}
{{- end }}

{{- if or $override (hasPrefix "dev" $tag) (contains "dev" $tag) (contains "latest" $tag) }}
  {{- /* Skip version check if override is set or tag contains 'dev' */}}
{{- else }}
  {{- $tagReplaced := replace "-" "." $tag }}
  {{- $parts := splitList "." $tagReplaced }}
  {{- if lt (len $parts) 3 }}
    {{- fail (printf "ERROR: image.tag '%s' is not in the expected 'YYYY.MM.DD' format after replacement." $tagReplaced ) }}
  {{- end }}
  {{- $year := int (index $parts 0) }}
  {{- $month := int (index $parts 1) }}
  {{- $day := int (index $parts 2) }}
  {{- $semver := printf "%d.%d.%d" $year $month $day }}

  {{- if not (semverCompare (printf ">= %s" $minVersion) $semver) }}
    {{- fail (printf "ERROR: The image.tag value (%s) is less than the minimum required version %s" .Values.image.tag $minVersion) }}
  {{- end }}
{{- end }}
{{- end -}}
