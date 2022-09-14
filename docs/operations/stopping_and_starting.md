# Stopping and starting OpsChain

This guide takes you through stopping and starting OpsChain without uninstalling.

After following this guide you should know:

- how to stop the OpsChain pods
- how to resume the OpsChain pods

## Stopping OpsChain

The pods that make up the OpsChain installation can be stopped to halt the OpsChain processes and free up any CPU or RAM that they use. Stopping OpsChain does not delete any persistent volumes (whereas uninstalling does).

The `opschain server stop` CLI subcommand will reduce all the Kubernetes replicas to zero to stop all the OpsChain pods.

_Warning: Do not use the `opschain server stop` command whilst steps and changes are being executed by OpsChain._

## Starting OpsChain

If the `opschain server stop` CLI subcommand has been used to stop OpsChain, then the `opschain server start` CLI subcommand can be used to start it again.
