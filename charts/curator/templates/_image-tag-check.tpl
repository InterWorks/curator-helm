{{- define "curator.checkImageTag" -}}

{{- $minVersion := semver "2025.5.1" }}

{{- $tag := .Values.image.tag | default "" | trim }}
{{- $override := .Values.image.tagOverride | default "" | trim }}

{{- if not $tag }}
  {{- fail "ERROR: image.tag is not set." }}
{{- end }}

{{- if or $override (hasPrefix "dev" $tag) (contains "dev" $tag) (contains "latest" $tag) }}
  {{- /* Skip version check if override is set or tag contains 'dev' */}}
{{- else }}
  {{- $tagClean := replace "-" "." $tag }}
  {{- $parts := splitList "." $tagClean }}
  {{- if lt (len $parts) 3 }}
    {{- fail (printf "ERROR: image.tag '%s' is not in the expected 'YYYY.MM.DD' format after replacement." $tagClean ) }}
  {{- end }}
  {{- $year := atoi (index $parts 0) }}
  {{- $month := atoi (index $parts 1) }}
  {{- $day := atoi (index $parts 2) }}
  {{- $parsedTag := semver (printf "%d.%d.%d" $year $month $day) }}

  {{- if not (semverCompare (printf ">= %s" $minVersion.String) $parsedTag.String) }}
    {{- fail (printf "ERROR: The image.tag value (%s) is less than the minimum required version %s. Parsed as %s" .Values.image.tag $minVersion.String $parsedTag.String) }}
  {{- end }}
{{- end }}

{{- end -}}
