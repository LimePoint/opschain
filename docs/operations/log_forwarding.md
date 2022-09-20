# OpsChain change log forwarding

If required, OpsChain's log aggregator can be configured to also forward change logs to external log storage. After following this guide you should know how to:

- add plugins to the OpsChain log aggregator
- configure change logs to be sent to external log storage

## Introduction

OpsChain uses [Fluentd](https://www.fluentd.org/) as its log aggregator. Fluentd provides an extensive framework that allows for custom developed and [pre-built plugins](https://www.fluentd.org/dataoutputs) to be used to forward logs to external log storage solutions. This guide provides the steps to configure OpsChain to forward change logs to a [Splunk HTTPS Event Collector](https://docs.splunk.com/Documentation/Splunk/8.2.1/Data/UsetheHTTPEventCollector).

## Data output plugins

To add additional output plugins to the OpsChain log aggregator, you should build a new container image that is based on the existing `limepoint/opschain-log-aggregator` image.

Most Fluentd output plugins can be installed by using the `fluent-gem install` command. For example, to install the Splunk output plugin your Dockerfile might look like this:

```Dockerfile
ARG OPSCHAIN_VERSION
FROM limepoint/opschain-log-aggregator:${OPSCHAIN_VERSION}

RUN fluent-gem install fluent-plugin-splunk-enterprise
```

You may also use the custom Dockerfile to include your company's private CA certificate if the output plugin you are using requires it to verify the TLS connection to your logging infrastructure.

```Dockerfile
ARG OPSCHAIN_VERSION
FROM limepoint/opschain-log-aggregator:${OPSCHAIN_VERSION}

RUN fluent-gem install fluent-plugin-splunk-enterprise

# add your company's private CA certificate
COPY myco-cacert.pem /etc/ssl/myco-cacert.pem
```

Once you have added the required customisations to the Dockerfile, build and push the image to your private image registry.

```shell
OPSCHAIN_VERSION='2022-04-11' # EXAMPLE ONLY - To find the current version for your OpsChain instance, you can run the `opschain info` CLI command
docker build --build-arg OPSCHAIN_VERSION --tag "image-registry.myco.com/myco/opschain-log-aggregator:${OPSCHAIN_VERSION}-1" .
docker push "image-registry.myco.com/myco/opschain-log-aggregator:${OPSCHAIN_VERSION}-1"
# builds and pushes an image tagged as image-registry.myco.com/myco/opschain-log-aggregator:2022-04-11-1
```

## Configure OpsChain to use your custom log aggregator

Once you have built and pushed your custom log aggregator image to your private registry, you can tell OpsChain to use it by overriding the `logAggregator.image` value in the OpsChain Helm chart.

```yaml
logAggregator:
  image: image-registry.myco.com/myco/opschain-log-aggregator:2022-04-11-1
```

If your internal registry requires credentials to pull this image, update the OpsChain [imagePullSecret](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/) config to allow this image to be pulled:

```shell
kubectl edit -n opschain secret opschain-image-secret
# modify the base64 encoded `.dockerconfigjson` value to add the additional credentials (don't remove the existing ones)
```

### Configuring your output plugins

The OpsChain Helm chart allows you to specify additional config that will be stored in a Kubernetes ConfigMap and mounted into the log-aggregator pod at runtime.

The configuration you add under the `logAggregator.additionalOutputConfig` will be read by Fluentd in the context of the [`copy` output plugin](https://docs.fluentd.org/output/copy) which OpsChain takes advantage of to send the OpsChain logs to multiple outputs.

Under the `copy` configuration, each `<store>` directive added instructs Fluentd to send the log entry to an additional target.

To enable sending the logs to Splunk, add configuration similar to the example below:

```yaml
logAggregator:
  image: image-registry.myco.com/myco/opschain-log-aggregator:2022-04-11-1
  additionalOutputConfig: |-
    <store>
      @type splunk_hec

      host splunk.myco.com
      port 8088
      token <Splunk HEC token>
      use_ssl true
      ssl_verify false
      ca_file /etc/ssl/myco-cacert.pem
    </store>

```

_Note: The specific configuration to include in `additionalOutputConfig` will depend on the plugin `@type` used. Please see Fluentd's [config file syntax](https://docs.fluentd.org/configuration/config-file) guide, and the relevant plugin manual for further information._

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
