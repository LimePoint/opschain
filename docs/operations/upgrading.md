# Upgrading

Before starting, ensure that your Docker daemon is running on your OpsChain host.

To upgrade OpsChain go to the location on your OpsChain host where you cloned the [OpsChain trial repository](https://github.com/LimePoint/opschain-trial), stop OpsChain, pull the latest changes from the remote git repository, and pull the latest Docker images.

```bash
cd opschain-trial
docker-compose down # or systemctl --user stop opschain.service if running OpsChain as a systemd service
git pull
docker-compose pull
```

If you are using the [OpsChain enterprise runner](../reference/opschain_and_mintpress.md#enterprise-controllers-for-oracle) you will need to pull the runner images:

```bash
OPSCHAIN_RUNNER_IMAGE=limepoint/opschain-runner-enterprise:latest docker-compose pull opschain-runner-devenv
OPSCHAIN_RUNNER_IMAGE=limepoint/opschain-runner:latest docker-compose pull opschain-runner-devenv
```

Then OpsChain can be started again:

```bash
docker-compose up # or systemctl --user start opschain.service if running OpsChain as a systemd service
```

If you are using the OpsChain CLI native binaries then these should be [downloaded](../reference/cli.md#opschain-native-cli) for the current version.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../../LICENCE)
