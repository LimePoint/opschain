# Upgrading

Before starting, ensure that your Docker daemon is running on your OpsChain host.

To upgrade OpsChain go to the location on your OpsChain host where you cloned the [OpsChain release repository](https://github.com/LimePoint/opschain-release), stop OpsChain, pull the latest changes from the remote git repository, and pull the latest Docker images.

```bash
cd opschain-release
docker-compose down # or systemctl --user stop opschain.service if running OpsChain as a systemd service
git pull
docker-compose pull
```

Then OpsChain can be started again:

```bash
docker-compose up # or systemctl --user start opschain.service if running OpsChain as a systemd service
```

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../../LICENCE)
