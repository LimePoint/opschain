# Uninstalling OpsChain

If at some point you decide that OpsChain is not for you and you no longer wish to continue using the services it provides, follow these steps to permanently remove OpsChain from your machine.

## Stop OpsChain containers

Terminate the running OpsChain containers by executing the following command.

```bash
docker-compose down
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

Run the following command to logout the `opschaintrial` user from Docker Hub.

```bash
docker logout
```

## Delete .opschainrc file

Remove the `.opschainrc` file that you created from the [create an OpsChain CLI configuration file](../getting_started/installation.md#create-an-opschain-cli-configuration-file) section in the installation guide.

```bash
rm ~/.opschainrc
```

## Delete the OpsChain directory

Remove the `opschain-trial` directory that you cloned from the [clone the OpsChain trial repository](../getting_started/installation.md#clone-the-opschain-trial-repository) section in the installation guide.

_Note: This will also remove your project and data files unless you specified a different folder for your OpsChain data during the [configure](../getting_started/installation.md#configure-the-opschain-environment) step. Verify the `OPSCHAIN_DATA_DIR` variable in your `.env` file and remove that folder separately if it's outside the `opschain-trial` folder._

## Uninstall native CLI

Delete the binary file if you opted to use the native CLI in the [download the native CLI (optional)](../getting_started/installation.md#download-the-native-cli-optional) section in the installation guide.

## Uninstall prerequisites (optional)

If no longer required, you may opt to uninstall the prerequisites detailed in the [required software](../getting_started/installation.md#required-software) section in the installation guide.
