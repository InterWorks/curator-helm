# curator

![Version: 2.1.0](https://img.shields.io/badge/Version-2.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2025.08-03](https://img.shields.io/badge/AppVersion-2025.08--03-informational?style=flat-square)

A Helm chart for Curator in a Container in Kubernetes

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.behavior | object | `{}` | scaling behavior |
| autoscaling.enabled | bool | `false` | enable autoscaling |
| autoscaling.maxReplicas | string | `nil` | maximum number of replicas |
| autoscaling.metrics | list | `[]` | scaling metrics |
| autoscaling.minReplicas | string | `nil` | minimum number of replicas |
| cronjob.affinity | object | `{}` |  |
| cronjob.env | object | `{}` |  |
| cronjob.successfulJobsHistoryLimit | int | `1` |  |
| curator.auth.existingSecret | string | `"curator-auth"` | secret to use for initial admin user |
| curator.cache.prefix | string | `""` | cache prefix |
| curator.config | object | `{}` | These are used to override default php config files present in the containers. The files are mounted in the config directory and will append .php to the ends of the keys |
| curator.env | object | `{}` | environment variables to set in the container |
| curator.envFromSecret | list | `[]` | read environment variables from a secret |
| curator.livenessProbe.failureThreshold | int | `3` | Number of failures before pod is failed |
| curator.livenessProbe.periodSeconds | int | `10` | Period to wait between checks |
| curator.livenessProbe.timeoutSeconds | int | `15` | Timeout for probe |
| curator.startupProbe.failureThreshold | int | `10` |  |
| curator.startupProbe.initialDelaySeconds | int | `10` |  |
| curator.startupProbe.periodSeconds | int | `10` |  |
| curator.startupProbe.timeoutSeconds | int | `5` | Timeout for probe |
| environment | string | `"prod"` | Required to be either prod, qa, or dev |
| fullnameOverride | string | `""` | Overrides the full name of the chart, default is the name of the release |
| image | object | `{"pullPolicy":"IfNotPresent","registry":"ghcr.io/interworks","repository":"curator","tag":"latest"}` | Image configuration |
| image.pullPolicy | string | `"IfNotPresent"` | Image Pull Policy |
| image.registry | string | `"ghcr.io/interworks"` | Registry URL |
| image.repository | string | `"curator"` | Repository name |
| image.tag | string | `"latest"` | Tag Name, overrides the default appVersion in Chart.yaml |
| ingress.className | string | `nil` | Ingress Class Name |
| ingress.enabled | bool | `true` | Control for ingress |
| ingress.hosts | list | `[]` | Ingress hosts configuration |
| ingress.tls | list | `[]` | TLS config |
| mariadbOperator.backup.bucket | string | `""` | s3 bucket to store backups |
| mariadbOperator.backup.region | string | `""` | s3 region for bucket |
| mariadbOperator.backup.retention | string | `"168h"` | retention period for backups |
| mariadbOperator.backup.schedule | string | `"0 0 * * *"` | schedule to take backups |
| mariadbOperator.backup.suspend | bool | `false` | suspend backups, if true, no backups will be created |
| mariadbOperator.database.characterSet | string | `"utf8"` | character set for the database |
| mariadbOperator.database.collate | string | `"utf8_general_ci"` | collation for the database |
| mariadbOperator.database.name | string | `"production"` | database to create |
| mariadbOperator.enabled | bool | `true` |  |
| mariadbOperator.mariaDbName | string | `"curator-mariadb"` | Name of existing mariadb resource |
| mariadbOperator.mariadbEndpoint | string | `""` | Endpoint to connect to mariadb, if not set it will use the mariaDbName as the hostname |
| mariadbOperator.user.grantOption | bool | `false` | grantOption for the user |
| mariadbOperator.user.host | string | `"%"` | allowable login hosts for the user |
| mariadbOperator.user.maxUserConnections | int | `100` | maximum number of connections for the user |
| mariadbOperator.user.userPasswordSecretKeyRef | object | `{"key":"password","name":"production-mariadb"}` | secret reference for the created user password |
| mariadbOperator.user.username | string | `"curator"` | mariadb user to create |
| nameOverride | string | `""` | Overrides the chart name, default is the name of the release |
| nodeSelector | object | `{}` |  |
| persistence.accessModes | list | `[]` | persistent volume claim accessMode |
| persistence.annotations | object | `{}` | persistent volume claim annotations |
| persistence.enabled | bool | `true` | enable persistence |
| persistence.existingClaim | string | `""` | existingClaim is the name of an existing persistent volume claim to use for storage |
| persistence.labels | object | `{}` | persistent volume claim labels |
| persistence.s3.bucket | string | `"some-bucket"` | bucket to use for storage |
| persistence.s3.enabled | bool | `false` | enable S3 storage, if disable and peristence.enabled is true, it will use PVC |
| persistence.s3.region | string | `""` | region bucket is in |
| persistence.size | string | `"5Gi"` | size of persistent volume claim |
| persistence.storageClass | string | `nil` | persistent volume claim storageClass |
| persistence.subPath | string | `""` | persistent volume claim subpath |
| podDisruptionBudget.enabled | bool | `true` | Enable Pod Disruption Budget |
| podDisruptionBudget.maxUnavailable | string | `nil` | Max Unavailable pods, default is 1 |
| podDisruptionBudget.minAvailable | string | `nil` | Min Available pods, default is 1 |
| podDisruptionBudget.selector | object | `{}` | Selector for the PDB |
| podSecurityContext | object | `{}` |  |
| replicaCount | string | `nil` | Number of replicas to deploy |
| resources | object | `{}` | Resource configuration, environment will control resources if left blank but can be overridden |
| securityContext | object | `{}` |  |
| service.port | int | `8080` | Service Port |
| service.type | string | `"ClusterIP"` | Service Type |
| serviceAccount.annotations | object | `{}` | Annotations for the service account |
| serviceAccount.automountServiceAccountToken | bool | `false` | Set this toggle to false to opt out of automounting API credentials for the service account |
| serviceAccount.create | bool | `true` | Specifies whether a ServiceAccount should be created |
| serviceAccount.imagePullSecrets | list | `[]` | Image pull secrets for the service account |
| serviceAccount.labels | object | `{}` | Labels for the service account |
| serviceAccount.name | string | `nil` | The name of the ServiceAccount to use. If not set and create is true, a name is generated using the fullname template |
| tolerations | list | `[]` |  |
| topologySpreadConstraints | list | `[]` | Pod Topology Spread Constraints |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
