# Upgrading

To upgrade OpsChain go to the location on your OpsChain host where you store your OpsChain server configuration (e.g. `~/opschain-configuration`), [download and install the latest CLI](../reference/cli.md#installation), and deploy the latest version of OpsChain (which will pull the latest images).

```bash
cd ~/opschain-configuration # or the directory where you store your OpsChain server configuration
# download and install the latest CLI
opschain server configure
# reapply any manual modifications to values.yaml - the old values.yaml will be stored as a backup by the configure script, alternatively a values.override.yaml file could be used
opschain server deploy
# we suggest committing your config to Git after upgrade
```

## Configure overrides

Any configuration modifications that need to be applied to `values.yaml` during the upgrade can be stored in a `values.override.yaml` file in the same directory.

Configuration from this file is automatically applied by the OpsChain CLI - [learn more](/docs/reference/cli.md#configuration-overrides).

## Updating runner images in the OpsChain registry

OpsChain will not automatically remove old images in the registry during the upgrade process. This means that old runner images may still exist in the registry. OpsChain provides some utilities to remove these old images and free up some disk space.

### List runner image tags in the registry

```bash
opschain server utils list_runner_image_tags
```

### Remove a runner image tag from the registry

```bash
opschain server utils 'remove_runner_image_tag[<tag_to_remove>]'
```

The [internal registry garbage collection](maintenance/docker_image_cleanup.md#internal-registry-garbage-collection) will then remove these images from disk.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
