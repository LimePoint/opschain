# Building container images

OpsChain step runners are executed in unprivileged containers to maintain security. This means that Docker, BuildKit, and Buildah cannot be run within an OpsChain step runner container.

## Using remote tools to build images

OpsChain step runners can leverage external build infrastructure to build container images whilst maintaining security within the OpsChain stack. This means that the external tooling can follow an organisation's best practices, and then OpsChain can leverage that tooling.

### Using cloud image builders

Some cloud providers offer services for building container images - for example the [Azure Container Registry Tasks](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-tutorial-quick-task).

These can be used from OpsChain as normal.

### Using Kaniko

[Kaniko](https://github.com/GoogleContainerTools/kaniko) is a Kubernetes native tool for building container images.

A Kaniko instance can be used from an OpsChain step runner as normal.

_Note: The default `opschain-runner` [service account](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/) does not have permission to create pods within Kubernetes, hence new Kaniko containers cannot be created with the default setup. You can update the `opschain-runner` service account's roles ([see an example](https://github.com/LimePoint/opschain-examples-confluent/blob/master/k8s/namespace.yaml)), however care should be taken when adding permissions to the runner as this may create security issues.._

### Using Docker

OpsChain step runner containers can use their [custom step runner Dockerfile](concepts/step_runner.md#custom-step-runner-dockerfiles) to install the Docker CLI and interact with a remote Docker host, for example:

```Dockerfile
RUN dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo && dnf install -y docker-ce-cli
```

Then in the OpsChain properties add the configuration for the Docker host to use (this example uses SSH to access the remote Docker instance, but another authentication method could be used):

```json
{
  "opschain": {
    "env": {
      "DOCKER_HOST": "ssh://user@docker-remote-host"
    },
    "files": {
      "~/.ssh/id_rsa": {
        "content": "{{ssh key for docker-remote-host}}",
        "mode": "0600"
      },
      "~/.ssh/known_hosts": {
        "content": "{{known_hosts file for docker-remote-host}}",
        "mode": "0600"
        }
    }
  }
}
```

Now the `docker` command can be used within the step runner, but the actual commands will be run using the remote Docker host.

_Note: Docker volumes are mounted from the host running the daemon, so uses of Docker volumes will not mount paths from the OpsChain step runner, which may be confusing. Build contexts are transparently copied to the remote host._

### Using BuildKit

Similar to how Docker can be used remotely, [BuildKit](https://github.com/moby/buildkit) can be run on a remote host (or container) and leveraged from within the OpsChain step runner.

BuildKit provides the `buildctl` tool which can be used to perform builds against a remote BuildKit instance.

`buildctl` is a lower-level tool than Docker, so whilst it is an option, using Docker as suggested [above](#using-docker) may be simpler.

## Directly modifying images

The [skopeo](https://github.com/containers/skopeo) and [umoci](https://umo.ci/) tools can be used to retrieve and modify container images directly.

These tools can be installed as part of a [custom step runner Dockerfile](concepts/step_runner.md#custom-step-runner-dockerfiles), e.g.:

```dockerfile
RUN dnf install -y skopeo
RUN curl -L https://github.com/opencontainers/umoci/releases/latest/download/umoci.amd64 -o /usr/local/bin/umoci && chmod +x /usr/local/bin/umoci
```

### Example - adding files to an image

Below is an example of using skopeo and umoci to modify the contents of the Docker Library nginx image. This example is analogous to placing static web assets in a container as part of a web application deployment, or placing a WAR file into an application server container.

First, copy the base image from the remote registry using skopeo (this is using the [nginx image from Docker Hub](https://hub.docker.com/_/nginx)):

```bash
skopeo copy docker://nginx:alpine oci:nginx:alpine
```

Next, unpack the image to allow for modifications:

```bash
umoci unpack --rootless --image nginx:alpine bundle
```

Now perform any desired modifications - this is a simple example of modifying a file, but this could use files retrieved from a source like Artifactory:

```bash
echo 'Hello world' > bundle/rootfs/usr/share/nginx/html/index.html
```

Once the desired modifications have been made, use umoci to repack the image:

```bash
umoci repack --image nginx:demo bundle
```

Now skopeo can be used to upload the image to a registry, or the image could be exported as a Docker tarball for use by `docker load`:

```bash
# Example 1: copy the image into the main Docker Hub registry as organisation/nginx-testing:demo
$ skopeo copy --dest-creds '{{registry creds}}'  oci:nginx:demo docker://organisation/nginx-testing:demo

# Example 2: copy the image to a Docker tarball, upload `demo-image.tar` somewhere for use by Docker
$ skopeo copy --additional-tag nginx:demo oci:nginx:demo docker-archive:demo-image.tar
# e.g. load and run the image, assumes a remote Docker exists and is configured
$ docker -H ssh://username@remote-docker load < demo-image.tar
$ docker -H ssh://username@remote-docker run -p 8080:80 -d --name nginx-demo nginx:demo
$ curl remote-docker:8080
Hello world
```

## Feedback

We're planning to enhance OpsChain's abilities to build container images in the future. If this is a feature you're interested in, we would love to [hear from you](/docs/support.md#how-to-contact-us) so that we can learn more about your use case.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
