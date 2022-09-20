# OpsChain backup & restore

OpsChain by itself does not perform backup and disaster recovery procedures. This guide assumes that you will be using a backup tool to backup and restore your Kubernetes cluster resources.

## Prerequisites

This guide assumes you have a Kubernetes backup tool to perform your backup and recovery procedures. Scroll down this page for [some options](#see-also).

## Creating a snapshot of your OpsChain resources

Prior to backing up your resources, we recommend stopping OpsChain:

```bash
opschain server stop
```

It is recommended that you backup the entire `opschain` namespace so that in an unlikely event of a failure, you can get OpsChain up and running after the recovery and restore process. Using the backup tool of your choice, make a snapshot of the `opschain` resources. In addition to the resources in the `opschain` namespace, the OpsChain persistent volumes that fulfil the persistent volume claims (in the `opschain` namespace) need to be backed up as well (e.g. database, Git repos, LDAP, step data). Once the snapshot has been created, you can restart OpsChain:

```bash
opschain server start
```

## Restoring a backup

Follow your backup tool's restore procedures if you need to restore a snapshot of your OpsChain Kubernetes resources.

## See also

Kubernetes backup options include [Velero](https://velero.io/), [Kasten K10](https://www.kasten.io/) and [Portworx](https://portworx.com/products/px-backup/). OpsChain does not make any recommendations on which backup tool you should use as it is outside the scope of our application.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
