# OpsChain change log forwarding

If required, OpsChain's log aggregator can be configured to also forward change logs to external log storage. After following this guide you should know how to:

- add plugins to the OpsChain log aggregator
- configure change logs to be sent to external log storage

## Introduction

OpsChain uses [Fluentd](https://www.fluentd.org/) as its log aggregator. Fluentd provides an extensive framework that allows for custom developed and [pre-built plugins](https://www.fluentd.org/dataoutputs) to be used to forward logs to external log storage solutions. This guide provides the steps to configure OpsChain to forward change logs to a [Splunk HTTPS Event Collector](https://docs.splunk.com/Documentation/Splunk/8.2.1/Data/UsetheHTTPEventCollector).

Note: The example commands below make reference to the OPSCHAIN_DATA_DIR environment variable. Please manually set this to the location of your OpsChain data directory, or `source .env` to make use of the existing configuration.

## Data output plugins

OpsChain allows for two methods to include plugins into the OpsChain log aggregator.

### `.rb` file plugins

If the plugin is a `.rb` file, copy the file into the `$OPSCHAIN_DATA_DIR/opschain_log_aggregator/plugin` folder. The OpsChain log aggregator will automatically load any files in this directory on container startup.

### `.gem` plugins

If the plugin is a gem, like the [Splunk Enterprise plugin](https://github.com/fluent/fluent-plugin-splunk) you will need to modify your `docker-compose.override.yml` to instruct the Fluentd to call `bundler` to install the gem.

#### Create a `Gemfile`

The following `Gemfile` will cause Fluentd to install the Splunk Enterprise plugin on container start:

```bash
cat << EOF > "${OPSCHAIN_DATA_DIR}/opschain_log_aggregator/bundler/Gemfile"
source 'https://rubygems.org'

gem 'fluent-plugin-splunk-enterprise'
EOF
```

Modify as required to reflect the gem(s) you require.

Note: All files in the `${OPSCHAIN_DATA_DIR}/opschain_log_aggregator/bundler` folder are mounted into `/opschain/bundler` in the container. If required, you can include the `.gem` files in this folder with the Gemfile specifying their location as:

```ruby
gem 'my_custom_plugin', path: '/opschain/bundler/my_custom_plugin'
```

#### Add the Gemfile to Fluentd

Edit your `docker-compose.override.yml` file, adding the `Gemfile` to the Fluentd commandline:

```text
  opschain-log-aggregator:
    command: --gemfile /opschain/bundler/Gemfile
```

## Configure change logs to be sent to external log storage

OpsChain takes advantage of the  [`copy` output plugin](https://docs.fluentd.org/output/copy) to send the OpsChain logs to multiple outputs.

### Create a `<store>` entry

Each `<store>` directive instructs Fluentd to send the log entry to an additional target. To enable sending the logs to Splunk create the configuration file as follows:

```bash
cat << EOF > "${OPSCHAIN_DATA_DIR}/opschain_log_aggregator/store.conf"
  <store>
    @type splunk_hec

    host <your Splunk hostname / ip>
    port <your Splunk HTTP event collector port>
    token <the Splunk token for the Event Collector>
    use_ssl true
    ssl_verify false
    ca_file /opschain/cacert.pem
  </store>
EOF
```

_Note: The specific configuration to include in `store.conf` will depend on the plugin `@type` used. Please see Fluentd's [Config File Syntax](https://docs.fluentd.org/configuration/config-file) guide, and the relevant plugin manual for further information._

### Splunk CA certificate

The example configuration provided above includes a reference to the Splunk server CA certificate. Copy the certificate into `${OPSCHAIN_DATA_DIR}/opschain_log_aggregator` to enable Fluentd to reference it when connecting to Splunk via HTTPS.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../../LICENCE)
