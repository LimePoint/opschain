# OpsChain change log retention

As part of system maintenance, it is recommended that the OpsChain change logs retention period be enabled and configured to limit disk usage. After following this guide you should know how to:

- automatically remove old change logs
- configure change log retention
- change when the log removal job runs

## Change log retention configuration

By default, OpsChain does not automatically remove old change logs.

Setting the log storage retention configuration means that any logs older than the configured number of days will be removed. The logs are removed based on the change finish time.

After a change's logs have been removed, any request for those logs (for example using `opschain change show-logs`) will return an error rather than the logs.

### Global

The global retention setting is used if a project or environment configuration is not present.

The global retention is set by setting the `OPSCHAIN_CHANGE_LOG_RETENTION_DAYS` environment variable in the `.env` file. After modifying the `.env` file OpsChain needs to be restarted.

```bash
docker-compose down
# update OPSCHAIN_CHANGE_LOG_RETENTION_DAYS to the desired value
vi .env
docker-compose up
```

### Project/environment

The global retention setting can be overridden by creating a `change_log_retention_days` config property within the project or environment properties. As with all properties, environment configuration values will override project configuration values.

Below is an example of setting this configuration via the [OpsChain properties](../reference/properties.md):

```json
{
  "opschain": {
    "config": {
      "change_log_retention_days": 30
    }
  },
  ...
}
```

This configuration then needs to be loaded into OpsChain using the `opschain project|environment set-properties` command.

The configuration can explicitly be set to `null` to disable log removal in this project or environment, overriding a higher level setting.

## Log removal job configuration

The log removal job runs daily by default.

The `OPSCHAIN_ARCHIVE_LOG_LINES_JOB_CRON` environment variable can be set in `.env` to change when/how the job runs.

Setting `OPSCHAIN_ARCHIVE_LOG_LINES_JOB_CRON=never` will prevent the log removal job from running.

For example, the log removal job could be configured to only run on weekends as follows:

```bash
docker-compose down
echo "OPSCHAIN_ARCHIVE_LOG_LINES_JOB_CRON='0 23 * * 6-7'" >> .env
docker-compose up
```

## See also

The OpsChain log aggregator can be configured to forward change logs to external log storage. See the [OpsChain change log forwarding](log_forwarding.md) guide for details.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../../LICENCE)
