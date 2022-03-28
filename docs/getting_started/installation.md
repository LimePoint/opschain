# OpsChain installation guide

This guide takes you through installing and configuring OpsChain.

After following this guide you should know how to:

- install OpsChain pre-requisites
- configure Docker Hub access
- install, configure and start OpsChain
- create an OpsChain user
- download the OpsChain CLI

## Prerequisites

### Required software

#### Git

In order to clone the latest release of the OpsChain repository you will need a [Git](https://git-scm.com/) client.

#### OpenSSL

As part of configuring the environment, the [OpenSSL](https://www.openssl.org/) utility is called to generate various keys.

#### Helm

You must have [Helm](https://helm.sh/docs/intro/install/) version 3 installed.

##### Kubernetes

OpsChain supports the following Kubernetes distributions on a single node only:

- macOS - Docker Desktop Community 3.1.0 and above
- Linux - the latest stable [`k3s`](https://k3s.io/) with the [Docker container runtime selected](https://rancher.com/docs/k3s/latest/en/advanced/#using-docker-as-the-container-runtime)
- Windows Subsystem for Linux (WSL) - the latest Docker Desktop release (installed in the WSL environment). Note:
  - _For a better CLI experience we suggest using a modern terminal (like the [Windows Terminal from the Microsoft Store](https://aka.ms/terminal) or a WSL terminal)._

### Hardware/VM requirements

OpsChain requires a minimum of 2GB of ram to function. We recommend 4GB if you intend to run our more advanced examples.

OpsChain requires a minimum of 30GB of disk to function. We recommend 100GB if you intend to run our examples without having to perform [manual cleanup activities](../operations/maintenance/docker_image_cleanup.md#opschain-docker-image-cleanup) very frequently.

If using Docker for Mac the [configuration UI](https://docs.docker.com/desktop/mac/#advanced) allows you to adjust the ram and disk allocation for Docker. After changing the configuration you will need to restart the Docker service.

If using Docker for Windows the [WSL configuration](https://docs.microsoft.com/en-us/windows/wsl/wsl-config#global-configuration-options-with-wslconfig) (or the per [distribution configuration](https://docs.microsoft.com/en-us/windows/wsl/wsl-config#per-distribution-configuration-options-with-wslconf)) allows you to modify the ram allocation. There is no need to adjust the disk allocation. If WSL is already running it will need to be restarted.

_Note: When using macOS or Windows we suggest ensuring that your Docker installation is not allocated too much of your system ram - or the rest of your system may struggle. As a rough guide, we suggest not allocating more than 50% of your system ram._

### Image registry hostname (Linux only)

The OpsChain image registry requires a hostname different to the OpsChain API hostname (that will resolve to the Kubernetes host) to allow it to route the registry traffic.

By default OpsChain will attempt to use `opschain-image-registry.local.gd` which resolves to `127.0.0.1`. If your Kubernetes host does not resolve this address (e.g. if `host opschain-image-registry.local.gd` fails), add `127.0.0.1 opschain-image-registry.local.gd` to your hosts file.

[`hostctl`](https://guumaster.github.io/) can be used to achieve this with the `hostctl add domains opschain opschain-image-registry.local.gd` command.

_Note: A hostname other that `opschain-image-registry.local.gd` can be used if desired - the value would need to be manually updated in the `.env` file after the `opschain-configure` script below has been run._

## Installation

### Clone the OpsChain trial repository

Clone the [OpsChain trial repository](https://github.com/LimePoint/opschain-trial) to your local machine using your preferred Git client.

```bash
git clone git@github.com:LimePoint/opschain-trial.git
cd opschain-trial
```

### Install the OpsChain licence

Copy the `opschain.lic` licence file into the current folder (`opschain-trial`).

### Create a GitHub personal access token

To access the private OpsChain repositories you will need to create a [GitHub personal access token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token).

This token will also be used for access to the example OpsChain Git repositories that been created to provide sample code for the getting started guide, and examples of how you might implement different types of changes.

### Add the OpsChain commands to the path

To add the OpsChain commands to the path run:

```bash
export PATH="$(pwd)/bin:$PATH" # set the path for the current shell
```

To make the change permanent the path can be modified in your shell config file, e.g.:

```bash
echo export PATH=\"$(pwd)/bin:'$PATH'\" >> ~/.zshrc # or ~/.bashrc if using bash
exec zsh # reload the shell config by starting a new session (replace zsh with bash as appropriate)
```

Alternatively, the OpsChain commands can be run without adding them to the path by specifying the full path to the command each time. The examples below assume the commands have been added to the path.

_The OpsChain commands do not support being executed via symlinks (i.e. `ln -s bin/opschain /usr/bin/opschain` will not work)._

### Install `cert-manager`

OpsChain depends on [`cert-manager`](https://cert-manager.io/) to manage its internal SSL/TLS certificates.

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.7.1 --set installCRDs=true
```

`cert-manager` is now ready for OpsChain to use - no additional `cert-manager` configuration is required.

_Please [contact OpsChain support](/docs/support.md#how-to-contact-us) if you would like the option to use OpsChain without installing `cert-manager`._

### Configure OpsChain

OpsChain needs to be configured before first run (and when upgrading) by executing the configuration script:

```bash
opschain-configure
```

You will be asked to confirm whether you would like to use certain features and provide your credentials for the OpsChain installation.

### Deploy the OpsChain containers

```bash
opschain-deploy
```

This will start the OpsChain server and its dependent services in separate Kubernetes pods. For more information on these containers see the [architecture overview](../reference/architecture.md).

The command may take several minutes to start, especially with slower internet connections as the OpsChain images are downloaded.

The `kubectl` command can be used to see the deployment progress:

```bash
kubectl get all -n opschain-trial
```

Once the `opschain-deploy` script has returned you can continue with the rest of the setup process.

### Create an OpsChain user

The OpsChain API server requires a valid username and password. To create a user, execute:

```bash
opschain-utils "create_user['opschain','password']"
```

_Note: Please ensure there are no spaces included in the parameter you supply to `opschain_utils`._

### Setup the OpsChain CLI

OpsChain has native CLI binaries for Windows, macOS and Linux.

[Read our documentation about downloading the native CLI](../reference/cli.md#opschain-cli-download) and then add it to your path (e.g. by copying it into the bin directory.)

Copy the example CLI configuration file to your home directory:

```bash
cp .opschainrc.example ~/.opschainrc
```

Verify that the username and password combination created earlier is reflected in the configuration file.

```bash
cat ~/.opschainrc
```

If you changed the username or password in the create_user command above, please edit the `.opschainrc` file to reflect your changes.

In addition, the `apiBaseUrl` configuration in `~/.opschainrc` must be updated to reflect the external OpsChain API address. This address reflects the  OpsChain listening port specified as part of the `opschain-configure` script. If you accepted the default setting, this will be `http://localhost:3000/`.

Learn more about the `opschainrc` configuration in the [CLI configuration guide](../reference/cli.md#opschain-cli-configuration).

_Note: If you create a `.opschainrc` file in your current directory, this will be used in precedence to the version in your home directory._

### Setup the custom CA (macOS only)

On macOS, to ensure that the OpsChain registry certificate is trusted by Kubernetes the following setup is required:

```bash
kubectl -n opschain-trial get secret opschain-ca-key-pair -o jsonpath="{.data.ca\.crt}" | base64 -d > opschain-ca.pem
security add-trusted-cert -k ~/Library/Keychains/login.keychain-db -p ssl opschain-ca.pem
# You will be prompted for your admin password in a macOS dialog
```

Once that setup is complete you will need to restart Docker Desktop.

### Configure Docker Hub access (optional)

If you intend to use the `opschain-action`, `opschain-dev`, or `opschain-lint` developer utilities (used as aids when creating new action definitions) you will need to be logged in to [Docker Hub](https://hub.docker.com/) as the `opschaintrial` user (or, if you have an [enterprise licence for OpsChain](../reference/opschain_and_mintpress.md#enterprise-controllers-for-oracle), the `opschainenterprise` user). These are the same Docker credentials requested by the `opschain-configure` command.

```bash
docker login --username opschaintrial
```

TIP: use the DOCKER_CONFIG environment variable if you need to use multiple Docker Hub logins.

```bash
export DOCKER_CONFIG="$(pwd)/.docker" # this would need to be exported in all opschain-trial terminals
docker login --username opschaintrial
```

## What to do next

- (optional) OpsChain is supplied with an LDAP server for authentication. If you'd prefer to use your own LDAP server, follow the [OpsChain LDAP](../operations/opschain_ldap.md) guide to alter the OpsChain authentication configuration.
- Return to the [getting started guide](README.md) to learn more about OpsChain.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
