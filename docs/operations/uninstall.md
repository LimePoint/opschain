# Uninstalling OpsChain

If at some point you decide that OpsChain is not for you and you no longer wish to continue using the services it provides, follow these steps to permanently remove OpsChain from your machine.

## Remove the OpsChain containers and data

_Before uninstalling OpsChain we suggest [making a backup](maintenance/backups.md) in case you would like to restore any OpsChain data in the future._

Terminate and remove the running OpsChain containers (and associated data) by executing the following command:

```bash
opschain-uninstall
```

## Remove LimePoint Docker images

Remove the LimePoint images on your local machine to clear up disk space.

```bash
docker rmi $(docker images --filter=reference='limepoint/*' -q)
```

Alternatively, you can do a system prune to remove all unused Docker images and containers. Please keep in mind that if you are using Docker for other applications, this action will remove all Docker images and containers on your machine, not just the ones from the LimePoint organisation.

```bash
docker system prune -a
```

## Logout OpsChain from Docker

Run the following command to logout the `opschaintrial` user from Docker Hub. This step is only required if you ran the `docker login` step in the [install guide](installation.md#configure-docker-hub-access-optiona).

```bash
docker logout
```

## Delete .opschainrc file

Remove the `.opschainrc` file that you created from the [create an OpsChain CLI configuration file](installation.md#create-an-opschain-cli-configuration-file) section in the installation guide.

```bash
rm ~/.opschainrc
```

## Delete the OpsChain configuration files

Remove the configuration files that you created when [configuring Opschain](installation.md#configure-opschain)

## Uninstall native CLI

Delete the binary file if you opted to use the native CLI in the [download the native CLI (optional)](installation.md#download-the-native-cli-optional) section in the installation guide.

## Uninstall prerequisites (optional)

If no longer required, you may opt to uninstall the prerequisites detailed in the [required software](installation.md#required-software) section in the installation guide.
