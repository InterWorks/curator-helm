# curator

![Version: 2.2.0](https://img.shields.io/badge/Version-2.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2025.08-03](https://img.shields.io/badge/AppVersion-2025.08--03-informational?style=flat-square)

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
| curator.app | object | `{"appKeySecret":{"key":null,"name":null},"debug":null}` | environment variables to pass into app.php |
| curator.auth.existingSecret | string | `"curator-auth"` | secret to use for initial admin user |
| curator.cache | object | `{"driver":null,"host":null,"port":null,"prefix":null}` | environment variables to pass into cache.php |
| curator.cache.driver | string | `nil` | cache type, possible values apc, array, database, file, memcached, redis |
| curator.cache.host | string | `nil` | memcached host, only used when driver is memcached |
| curator.cache.port | string | `nil` | memcached port, only used when driver is memcached |
| curator.cache.prefix | string | `nil` | cache prefix, defaults to a value derived from APP_NAME if unset |
| curator.cms | object | `{"assetCache":null,"assetMinify":null,"enableCSRF":null,"filesystemDriver":null,"filesystemMediaPath":null,"filesystemUploadsPath":null,"routesCache":null}` | environment variables to pass into cms.php |
| curator.cms.filesystemDriver | string | `nil` | disk used for CMS media/uploads storage, defaults to "s3" if persistence.s3.enabled else "local" |
| curator.config | object | `{}` | If one of these is defined the above config section will no longer be applicable if the new config doesn't utilze environment variables |
| curator.database.connection | string | `nil` |  |
| curator.database.databaseName | string | `nil` |  |
| curator.database.host | string | `nil` |  |
| curator.database.password.secretKeyRef.key | string | `nil` |  |
| curator.database.password.secretKeyRef.name | string | `nil` |  |
| curator.database.username | string | `nil` |  |
| curator.env | object | `{}` | environment variables to set in the container |
| curator.envFromSecret | list | `[]` | read environment variables from a secret |
| curator.filesystems | object | `{"disk":null}` | environment variables to pass into filesystems.php |
| curator.filesystems.disk | string | `nil` | default filesystem disk, defaults to "s3" if persistence.s3.enabled else "local" |
| curator.livenessProbe.failureThreshold | int | `3` | Number of failures before pod is failed |
| curator.livenessProbe.periodSeconds | int | `10` | Period to wait between checks |
| curator.livenessProbe.timeoutSeconds | int | `15` | Timeout for probe |
| curator.logging.channel | string | `nil` |  |
| curator.logging.deprecationsChannel | string | `nil` |  |
| curator.logging.level | string | `nil` |  |
| curator.mail.ehloDomain | string | `nil` |  |
| curator.mail.fromAddress | string | `nil` |  |
| curator.mail.fromName | string | `nil` |  |
| curator.mail.host | string | `nil` |  |
| curator.mail.passwordSecretRef.key | string | `nil` |  |
| curator.mail.passwordSecretRef.name | string | `nil` |  |
| curator.mail.port | string | `nil` |  |
| curator.mail.username | string | `nil` |  |
| curator.powerbi.adminClientIdSecretRef.key | string | `nil` |  |
| curator.powerbi.adminClientIdSecretRef.name | string | `nil` |  |
| curator.powerbi.adminClientSecretSecretRef.key | string | `nil` |  |
| curator.powerbi.adminClientSecretSecretRef.name | string | `nil` |  |
| curator.powerbi.cacheEnabled | string | `nil` |  |
| curator.powerbi.cacheExpirySeconds | string | `nil` |  |
| curator.powerbi.clientIdSecretRef.key | string | `nil` |  |
| curator.powerbi.clientIdSecretRef.name | string | `nil` |  |
| curator.powerbi.clientSecretSecretRef.key | string | `nil` |  |
| curator.powerbi.clientSecretSecretRef.name | string | `nil` |  |
| curator.powerbi.redirectURI | string | `nil` |  |
| curator.powerbi.tenant | string | `nil` |  |
| curator.queue.connection | string | `nil` |  |
| curator.session.cookie | string | `nil` |  |
| curator.session.driver | string | `nil` |  |
| curator.session.secureCookie | string | `nil` |  |
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
| persistence.s3.accessKeyIdSecret | object | `{"key":null,"name":null}` | secret containing the AWS access key id, leave unset to rely on IRSA/instance role credentials |
| persistence.s3.bucket | string | `"some-bucket"` | bucket to use for storage |
| persistence.s3.enabled | bool | `false` | enable S3 storage, if disable and peristence.enabled is true, it will use PVC |
| persistence.s3.endpoint | string | `nil` | custom S3-compatible endpoint, leave unset to use AWS |
| persistence.s3.region | string | `""` | region bucket is in |
| persistence.s3.secretAccessKeySecret | object | `{"key":null,"name":null}` | secret containing the AWS secret access key, leave unset to rely on IRSA/instance role credentials |
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
