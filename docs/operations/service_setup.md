# Setting up OpsChain as a systemd service

This guide takes you through configuring OpsChain as a systemd service.

After following this guide you should know:

- how to run services as a non-root users on boot
- how to run OpsChain as a systemd service

## Run services on boot as non-root users

To enable systemd services to run as a non-root user (e.g. `opschain`) on boot the following command needs to be run:

```bash
loginctl enable-linger opschain
```

### Additional configuration for RHEL-7

On RHEL-7-like systems, non-root users (e.g. `opschain`) need to be configured to allow them to run services via systemd. This is done by creating a service for that user as follows. This needs to be done as the root user.

```bash
$ cat > /etc/systemd/system/user@$(id -u opschain).service <<EOH
[Unit]
Description=User Manager for UID %i
After=systemd-user-sessions.service
After=user-runtime-dir@%i.service
Wants=user-runtime-dir@%i.service

[Service]
LimitNOFILE=infinity
LimitNPROC=infinity
User=%i
PAMName=systemd-user
Type=notify
PermissionsStartOnly=true
ExecStartPre=/bin/loginctl enable-linger %i
ExecStart=-/lib/systemd/systemd --user
Slice=user-%i.slice
KillMode=mixed
Delegate=yes
TasksMax=infinity
Restart=always
RestartSec=15

[Install]
WantedBy=default.target
EOH
```

Then enable and start the service:

```bash
systemctl daemon-reload
systemctl enable user@$(id -u opschain).service
systemctl start user@$(id -u opschain).service
```

### Setting up OpsChain as a service

OpsChain can be run as a systemd service as the root user or as a non-root user. This guide documents the steps for running it as a service as the non-root user. If doing it as the root user the service path will need to change - most likely to a path under `/etc/systemd/system`.

Create the OpsChain service unit file as the non-root user (e.g. `opschain`):

```bash
mkdir -p ~/.local/share/systemd/user/
# the DOCKER_HOST environment variable needs to be set if a custom value is being used (e.g. if using rootless docker)
$ cat > ~/.local/share/systemd/user/opschain.service <<EOH
[Unit]
Description=Unify Change: Connect, automate, and orchestrate
Documentation=https://opschain.io
Requires=docker.service

[Install]
WantedBy=default.target

[Service]
Environment=DOCKER_HOST=$DOCKER_HOST
Environment=PATH=/home/$(id -nu)/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
WorkingDirectory=/home/$(id -nu)/opschain-release
ExecStartPre=/home/$(id -nu)/bin/docker info
ExecStartPre=-/home/$(id -nu)/bin/docker-compose down
ExecStart=/home/$(id -nu)/bin/docker-compose up
ExecStop=/home/$(id -nu)/bin/docker-compose down
TimeoutStartSec=0
TimeoutStopSec=60
RestartSec=2
Restart=always

StartLimitBurst=3
StartLimitInterval=60s
EOH
```

_Note that the paths will vary if you've installed OpsChain to a different location, or if you are using a system-wide Docker installation._

Now enable and start the service:

```bash
systemctl --user daemon-reload
systemctl --user enable opschain.service
systemctl --user start opschain.service
```

#### Viewing the OpsChain service logs

To view logs for this service the `--user-unit` argument needs to be passed to `journalctl`:

```bash
journalctl --user-unit opschain
```

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../../LICENCE)
