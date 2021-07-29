# OpsChain backup & restore

After following this guide you should know how to:

- Create and restore a backup of your OpsChain data

## Creating a backup

OpsChain needs to be stopped to make a backup.

```bash
docker-compose down
```

Once OpsChain is down a backup can be made of the `opschain_data` directory.

```bash
tar -cvJf opschain_data.tar.xz opschain_data
```

Once the backup has been created OpsChain can be started again.

```bash
docker-compose up
```

### OpsChain rootless Docker installs

OpsChain Rootless Docker installs may encounter permissions issues running these steps.

The `opschain-ops` container can be used to handle this situation.

This container also has the `opschain-release` directory bind mounted at `/opschain-release`. This make it possible to make backups using this container.

```bash
docker-compose run --rm opschain-ops tar -cvJf /opschain-release/opschain-backup.tar.xz /opschain_data
```

This will create the `opschain-backup.tar.xz` in the `opschain-release` directory.

The [file ownership](rootless_install.md#file-ownership) section of the OpsChain Rootless install documentation provides more details.

## Restoring a backup

OpsChain needs to be stopped when restoring a backup.

```bash
docker-compose down
```

Once OpsChain is down remove/move any existing data and then restore your backup tarball.

```bash
mv opschain_data opschain_data.old
tar -xvJf opschain_data.tar.xz
```

Once the backup has been restored OpsChain can be started again.

```bash
docker-compose up
```

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../../LICENCE)
