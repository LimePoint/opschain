# Upgrading

To upgrade OpsChain go to the location on your local machine where you cloned the [OpsChain Release repository](https://github.com/LimePoint/opschain-release), shut down OpsChain, pull the latest changes from the remote git repository, and pull the latest Docker images.

```bash
$ cd opschain-release
$ docker-compose down
$ git pull
$ docker-compose pull
```

_Note: Ensure that your Docker daemon is running._
