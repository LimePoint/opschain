# OpsChain Docker image cleanup

As part of regular system maintenance it is recommended that the OpsChain runner images are regularly pruned to limit disk usage. After following this guide you should know how to:

- remove older OpsChain images
- remove images for a specific change

## Docker images

OpsChain builds Docker images whenever a change is run. These images are not tagged however OpsChain adds Docker labels to allow for simplified cleanup.

If no cleanup is performed then these images will continue to consume disk space.

### Removing older OpsChain images

The following command will remove unused OpsChain Docker images (`label=opschain=true`) that were created over 72 hours ago (`until=72h`).

```bash
docker image prune --filter 'label=opschain=true' --filter 'until=72h'
```

If these images are not required for audit purposes it is suggested a cron job (or similar) is created to execute this command to free up disk space.

### Removing OpsChain images for a particular change

The change ID is shown during change creation. The following command will remove unused OpsChain Docker images that exist for change `abc123`.

```bash
docker image prune --filter 'label=opschain.change_id=abc123'
```

### Internal registry garbage collection

Step runner images are built whenever a change runs a step. OpsChain runs a garbage collection process to remove these images after 24 hours. If you need more control of this process please [contact us](/docs/support.md#how-to-contact-us).

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
