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

OpsChain requires a minimum of 30GB of disk to function. We recommend 100GB if you intend to run our examples without having to perform [manual cleanup activities](maintenance/docker_image_cleanup.md#opschain-docker-image-cleanup) very frequently.

If using Docker for Mac the [configuration UI](https://docs.docker.com/desktop/mac/#advanced) allows you to adjust the ram and disk allocation for Docker. After changing the configuration you will need to restart the Docker service.

If using Docker for Windows the [WSL configuration](https://docs.microsoft.com/en-us/windows/wsl/wsl-config#global-configuration-options-with-wslconfig) (or the per [distribution configuration](https://docs.microsoft.com/en-us/windows/wsl/wsl-config#per-distribution-configuration-options-with-wslconf)) allows you to modify the ram allocation. There is no need to adjust the disk allocation. If WSL is already running it will need to be restarted.

_Note: When using macOS or Windows we suggest ensuring that your Docker installation is not allocated too much of your system ram - or the rest of your system may struggle. As a rough guide, we suggest not allocating more than 50% of your system ram._

### Image registry hostname (Linux only)

The OpsChain image registry requires a hostname different to the OpsChain API hostname (that will resolve to the Kubernetes host) to allow it to route the registry traffic.

By default OpsChain will attempt to use `opschain-image-registry.local.gd` which resolves to `127.0.0.1`. If your Kubernetes host does not resolve this address (e.g. if `host opschain-image-registry.local.gd` fails), add `127.0.0.1 opschain-image-registry.local.gd` to your hosts file.

[`hostctl`](https://guumaster.github.io/) can be used to achieve this with the `hostctl add domains opschain opschain-image-registry.local.gd` command.

_Note: A hostname other than `opschain-image-registry.local.gd` can be used if desired - the value would need to be manually updated in the `.env` file and `values.yaml` file after the `opschain server configure` script below has been run. Alternatively the value could be added to a [`values.override.yaml` configuration override file](/docs/reference/cli.md#configuration-overrides) - [see an example](/config_file_examples/values.override.yaml.example)._

## Installation

### Install the OpsChain licence

Copy the `opschain.lic` licence file into the current folder or set the `OPSCHAIN_LICENCE` environment variable to the path where you stored `opschain.lic`.

### Create a GitHub personal access token

To access the private OpsChain repositories you will need to create a [GitHub personal access token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token).

This token will also be used for access to the example OpsChain Git repositories that been created to provide sample code for the getting started guide, and examples of how you might implement different types of changes.

### Install `cert-manager`

OpsChain depends on [`cert-manager`](https://cert-manager.io/) to manage its internal SSL/TLS certificates.

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.9.1 --set installCRDs=true
```

`cert-manager` is now ready for OpsChain to use - no additional `cert-manager` configuration is required.

_Please [contact OpsChain support](/docs/support.md#how-to-contact-us) if you would like the option to use OpsChain without installing `cert-manager`._

### Install the OpsChain CLI

OpsChain has native CLI binaries for Windows, macOS and Linux. See the [installation](../reference/cli.md#installation) section of our CLI reference guide to download and configure the `opschain` executable.

The OpsChain CLI is used to configure the OpsChain server installation.

### Configure OpsChain

OpsChain needs to be configured before first run (and when upgrading) by executing the `opschain server configure` command. This command will generate (or update) a number of configuration files in the current directory. For this reason we recommend creating a specific OpsChain configuration folder that should be used whenever you execute any `opschain server` subcommands.

```bash
mkdir ~/opschain-configuration # use another directory as desired
cd ~/opschain-configuration
opschain server configure
```

You will be asked to confirm whether you would like to use certain features and provide your credentials for the OpsChain installation.

_Note: all future `opschain server` commands must be run in the `~/opschain-configuration` (or equivalent) directory to ensure that the right configuration is used._

### Deploy the OpsChain containers

```bash
opschain server deploy
```

This will start the OpsChain server and its dependent services in separate Kubernetes pods. For more information on these containers see the [architecture overview](../reference/architecture.md).

The command may take several minutes to start, especially with slower internet connections as the OpsChain images are downloaded.

The `kubectl` command can be used to see the deployment progress:

```bash
kubectl get all -n opschain
```

Once the `opschain server deploy` script has returned you can continue with the rest of the setup process.

### Create an OpsChain user

The OpsChain API server requires a valid username and password. To create a user, execute:

```bash
opschain server utils "create_user['opschain','password']"
```

_Note: Please ensure there are no spaces included in the parameter you supply to `opschain server utils`._

### Configure the OpsChain CLI's API access

Create a CLI configuration file in your home directory based on the [example](/config_file_examples/opschainrc.example):

```bash
vi ~/.opschainrc
```

If you changed the username or password in the `create_user` command above, ensure you modify the `.opschainrc` file to reflect your changes.

In addition, the `apiBaseUrl` configuration in `~/.opschainrc` must be updated to reflect the external OpsChain API address. This address reflects the OpsChain listening port specified as part of the `opschain server configure` script. If you accepted the default setting, this will be `http://localhost:3000/`.

Learn more about the `opschainrc` configuration in the [CLI configuration guide](../reference/cli.md#opschain-cli-configuration).

_Note: If you create a `.opschainrc` file in your current directory, this will be used in precedence to the version in your home directory._

### Setup the custom CA (macOS only)

On macOS, to ensure that the OpsChain registry certificate is trusted by Kubernetes the following setup is required (_*Note: Once this setup is complete you must restart Docker Desktop*_).

```bash
kubectl -n opschain get secret opschain-ca-key-pair -o jsonpath="{.data.ca\.crt}" | base64 -d > opschain-ca.pem
security add-trusted-cert -k ~/Library/Keychains/login.keychain-db -p ssl opschain-ca.pem
# You will be prompted for your admin password in a macOS dialog
# Remember to restart Docker Desktop once these commands have completed
```

### Configure Docker Hub access (optional)

If you intend to use the OpsChain development environment (used when creating new action definitions) you will need to be logged in to [Docker Hub](https://hub.docker.com/) as the `opschaintrial` user (or, if you have an [enterprise licence for OpsChain](../reference/opschain_and_mintpress.md#enterprise-controllers-for-oracle), the `opschainenterprise` user). These are the same Docker credentials requested by the `opschain server configure` command.

```bash
docker login --username opschaintrial
```

TIP: use the DOCKER_CONFIG environment variable if you need to use multiple Docker Hub logins.

```bash
export DOCKER_CONFIG="$(pwd)/.docker" # this would need to be exported in all terminals where OpsChain is being used
docker login --username opschaintrial
```

## What to do next

- (optional) OpsChain is supplied with an LDAP server for authentication. If you'd prefer to use your own LDAP server, follow the [OpsChain LDAP](opschain_ldap.md) guide to alter the OpsChain authentication configuration.
- Return to the [getting started guide](../getting_started/README.md) to learn more about OpsChain.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
