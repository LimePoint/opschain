# Upgrading

Before starting, ensure that your Docker daemon is running on your OpsChain host.

To upgrade OpsChain go to the location on your OpsChain host where you cloned the [OpsChain trial repository](https://github.com/LimePoint/opschain-trial), stop OpsChain, pull the latest changes from the remote git repository, and pull the latest Docker images.

```bash
cd opschain-trial
docker-compose down # or systemctl --user stop opschain.service if running OpsChain as a systemd service
git pull
docker-compose pull
```

Then OpsChain can be started again:

```bash
docker-compose up # or systemctl --user start opschain.service if running OpsChain as a systemd service
```

If you are using the OpsChain CLI native binaries then these should be [downloaded](../reference/cli.md#opschain-native-cli) for the current version.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../../LICENCE)
