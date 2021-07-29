# OpsChain Backup & Restore

After following this guide you should know how to:
- Create and restore a backup of your OpsChain data

## Creating a Backup

OpsChain needs to be stopped to make a backup.

```
$ docker-compose down
```

Once OpsChain is down a backup can be made of the `opschain_data` directory.

```
$ tar -cvJf opschain_data.tar.xz opschain_data
```

Once the backup has been created OpsChain can be started again.

```
$ docker-compose up
```

### OpsChain Rootless Docker Installs

OpsChain Rootless Docker installs may encounter permissions issues running these steps.

The `opschain-ops` container can be used to handle this situation.

This container also has the `opschain-release` directory bind mounted at `/opschain-release`. This make it possible to make backups using this container.

```
$ docker-compose run --rm opschain-ops tar -cvJf /opschain-release/opschain-backup.tar.xz /opschain_data
```

This will create the `opschain-backup.tar.xz` in the `opschain-release` directory.

The [File Ownership](rootless_install.md#file-ownership) section of the OpsChain Rootless install documentation provides more details.

## Restoring a Backup

OpsChain needs to be stopped when restoring a backup.

```
$ docker-compose down
```

Once OpsChain is down remove/move any existing data and then restore your backup tarball.

```
$ mv opschain_data opschain_data.old
$ tar -xvJf opschain_data.tar.xz
```

Once the backup has been restored OpsChain can be started again.

```
$ docker-compose up
```

## Licence & Authors
- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../../LICENCE)
