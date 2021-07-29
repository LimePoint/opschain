# Installing OpsChain on Rootless Docker

This guide takes you through installing rootless Docker for use with OpsChain.

After following this guide you should know:

- how to install and configure rootless Docker for OpsChain
- how to install and configure OpsChain

This guide is designed for RHEL-like platforms.

For more information on running rootless Docker, see the [rootless mode documentation](https://docs.docker.com/engine/security/rootless/) provided by Docker.

## System Preparation

OpsChain needs a kernel newer than 4.18. If possible, a kernel newer than 5.11 is preferred - we suggest using the newest available/supported kernel in the distribution you are using. The following commands can be run to check the kernel version and the update can optionally be run as root to get the latest kernel.

```bash
$ uname -r # the version reported needs to be 4.18 or higher
4.18.0-240.1.1.el8_3.x86_64
dnf update kernel # we suggest updating the kernel - using the latest UEK instead is suggested if using Oracle Linux
reboot # if a kernel update performed
```

The `git`, `openssl` and `iptables` packages must be installed. The following command can be run as root to install them:

```bash
dnf install -y git openssl iptables # yum can be used rather than dnf if dnf is not available
```

The `ip_tables` and `br_netfilter` modules need to be loaded and configured to load on boot, the following command can be run as root to configure them:

```bash
modprobe ip_tables br_netfilter
( echo ip_tables; echo br_netfilter ) >> /etc/modules-load.d/opschain.conf
```

SELinux needs to be configured to allow access to `/run/xtables.lock`, the following command can be run as root to configure access:

```bash
dnf install -y policycoreutils-python-utils
semanage permissive -a iptables_t
```

If the `policycoreutils-python-utils` package can't be installed (e.g. if using an older RHEL version) then SELinux can be disabled as a workaround, the following command can be run as root to disable SELinux:

```bash
setenforce 0
echo 'SELINUX=disabled' > /etc/selinux/config
```

If available (and using a kernel older than 5.11) the `fuse-overlayfs` package should be installed for optimal performance, the following command can be run as root to install it:

```bash
dnf install -y fuse-overlayfs # yum can be used rather than dnf if dnf is not available
```

_Note: If the package is not available you can still proceed through this guide._

### User Setup

The user that will run OpsChain and Docker needs to be created. It also needs to have subuids and subgids configured.

The new user account will need access to use Fuse. This is configured by default on RHEL-like platforms.

The following steps can be run as root to create the new user.

```bash
useradd opschain
# fallback steps for subuid/subgid, not required on most platforms
grep -q opschain /etc/subuid || echo 'opschain:100000:65536' >> /etc/subuid
grep -q opschain /etc/subgid || echo 'opschain:100000:65536' >> /etc/subgid
```

To allow this user account to view logs for systemd services, they need to be added to the `systemd-journal` group:

```bash
usermod -G systemd-journal -a opschain
```

When performing steps as the target user in this guide using `su` or `sudo` to swap to the target user account may cause issues with systemd/D-Bus. It is recommended that you SSH directly to the target host as the target user to avoid this.

***Note: All steps below are run as the target user rather than as root.***

## Rootless Docker Installation

Docker provides an installation script for rootless Docker.

Run the following steps as the non-root user (e.g. `opschain`) to install rootless Docker:

```bash
curl -fsSL https://get.docker.com/rootless > rootless-install
# verify the contents of rootless-install as desired
sh rootless-install
rm -f rootless-install
```

The output will include some environment variable configuration to add to the `~/.bashrc`. Modify this file and add the required lines, then logout and login again.

```bash
vi ~/.bashrc
# add the exports, then :wq
exit
```

OpsChain also uses `docker-compose` which can be installed as follows:

```bash
mkdir -p ~/bin
pushd ~/bin
curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-Linux-x86_64 -o docker-compose
chmod +x docker-compose
popd
```

### Optional - `fuse-overlayfs` Workaround

If the `fuse-overlayfs` package could not be installed and your kernel is older than 5.11 then the following workaround can be used.

```bash
pushd ~/bin
command -v fuse-overlayfs || wget https://cibuilder.mintpress.io/static/rootless/fuse-overlayfs
command -v fusermount3 || wget https://cibuilder.mintpress.io/static/rootless/fusermount3
compgen -G 'fuse*' && chmod +x fuse*
popd
```

### Configure the Docker Rootless Daemon

The steps from the [Run Services on Boot as Non-Root Users](service_setup.md#additional-configuration-for-rhel-7) guide need to be run if running on RHEL version 7 (or equivalent).

Create the Docker service unit file as the non-root user (e.g. `opschain`):

```bash
mkdir -p ~/.local/share/systemd/user/
$ cat > ~/.local/share/systemd/user/docker.service <<EOH
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com

[Install]
WantedBy=default.target

[Service]
Environment=PATH=/home/$(id -nu)/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ExecStartPre=-/bin/rm -rf "${XDG_RUNTIME_DIR}/docker"/*
ExecStart=/home/$(id -nu)/bin/dockerd-rootless.sh
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always

StartLimitBurst=3
StartLimitInterval=60s

LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity

TasksMax=infinity

# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes

OOMScoreAdjust=-500
EOH
```

Now enable and start the service:

```bash
systemctl --user daemon-reload
systemctl --user enable docker.service
systemctl --user start docker.service
```

#### Viewing the Docker Service Logs

To view logs for this service the `--user-unit` argument needs to be passed to `journalctl`:

```bash
journalctl --user-unit docker
```

#### Verify the Docker Service

Verify the Docker daemon is working by running the following:

```bash
docker run --rm hello-world
```

## OpsChain Install

OpsChain can now be installed as described in the [Getting Started](../getting_started.md#prerequisites) guide.

### Configure OpsChain as a Service

To configure the rootless installation of OpsChain as a service, first shutdown OpsChain if it is running:

```bash
docker-compose down
```

Then the steps from the [Setting up OpsChain as a Service](service_setup.md) guide can be followed to setup the OpsChain systemd service.

The steps from the [Run Services on Boot as Non-Root Users](service_setup.md#additional-configuration-for-rhel-7) guide need to be run if running on RHEL version 7 (or equivalent).

## File Ownership

Using rootless Docker means that some of the files under the `opschain_data` directory will be owned by one of the subuids/subgids of the non-root user (e.g. `opschain`).

This means the non-root user may encounter permission denied errors when trying to access those files, e.g.:

```bash
$ ls opschain_data/opschain_db/PG_VERSION
ls: cannot open directory 'opschain_data/opschain_db/PG_VERSION': Permission denied
```

To support this usecase OpsChain provides a Docker container that has full permissions to this directory.

```bash
[host] docker-compose run --rm opschain-ops
# inside the container with extra privileges
[container] ls /opschain_data/opschain_db/PG_VERSION
/opschain_data/opschain_db/PG_VERSION
[container] exit
```

Refer to the [OpsChain Backups](backups.md) guide for details on using this container to backup and restore OpsChain.

## Licence & Authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../../LICENCE)
