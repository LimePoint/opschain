# Upgrading

To upgrade OpsChain go to the location on your OpsChain host where you cloned the [OpsChain trial repository](https://github.com/LimePoint/opschain-trial), stop OpsChain, pull the latest changes from the remote git repository, and deploy the latest version of OpsChain (which will pull the latest images).

```bash
cd opschain-trial
git pull
opschain-configure
# reapply any manual modifications to values.yaml - the old values.yaml will be stored as a backup by the configure script
opschain-deploy
```

The updated OpsChain CLI native binaries (with the release date matching the current release (which can be found in the `RELEASE-VERSION` file in the `opschain-trial` repo or by running the `opschain info` CLI command)) must be [downloaded](../reference/cli.md#installation).

## Updating runner images in the OpsChain registry

OpsChain will not automatically remove old images in the registry during the upgrade process. This means that old runner images may still exist in the registry. OpsChain provides some utilities to remove these old images and free up some disk space.

### List runner image tags in the registry

```bash
opschain-utils list_runner_image_tags
```

### Remove a runner image tag from the registry

```bash
opschain-utils 'remove_runner_image_tag[<tag_to_remove>]'
```

The [internal registry garbage collection](maintenance/docker_image_cleanup.md#internal-registry-garbage-collection) will then remove these images from disk.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
