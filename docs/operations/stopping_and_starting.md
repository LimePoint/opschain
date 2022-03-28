# Stopping and starting OpsChain

This guide takes you through stopping and starting OpsChain without uninstalling.

After following this guide you should know:

- how to stop the OpsChain pods
- how to resume the OpsChain pods

## Stopping OpsChain

The pods that make up the OpsChain installation can be stopped to halt the OpsChain processes and free up any CPU or RAM that they use. Stopping OpsChain does not delete any persistent volumes (whereas uninstalling does).

The `opschain-stop` command provided in the `opschain-trial/bin` directory will reduce all the Kubernetes replicas to zero to stop all the OpsChain pods.

_Warning: Do not use the `opschain-stop` command whilst steps and changes are being executed by OpsChain._

## Starting OpsChain

If the `opschain-stop` script has been used to stop OpsChain, then the `opschain-start` command can be used to start it again.
