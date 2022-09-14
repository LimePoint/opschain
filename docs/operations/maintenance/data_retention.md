# OpsChain data retention

As part of system maintenance, it is recommended that the OpsChain change logs and event retention periods be enabled and configured to limit disk usage. After following this guide you should know how to:

- automatically remove old change logs and events
- configure change log and event retention
- change when the removal job runs

## Retention configuration

By default, OpsChain retains all change logs and events; i.e. it does not automatically remove this data based upon age.

### Event retention

Setting the event retention configuration means that events older than the configured number of days will be removed.

### Change log retention

Setting the change log storage retention configuration means that any logs older than the configured number of days will be removed. The logs are removed based on the change finish time. After a change's logs have been removed, any request for those logs (for example using `opschain change show-logs`) will return an error rather than the logs.

### Global

The global retention setting is used if a project or environment configuration is not present. It can be set by setting the `OPSCHAIN_CHANGE_LOG_RETENTION_DAYS` and/or `OPSCHAIN_EVENT_RETENTION_DAYS` environment variables in the `.env` file.

```bash
# update OPSCHAIN_CHANGE_LOG_RETENTION_DAYS or OPSCHAIN_EVENT_RETENTION_DAYS to the desired value, add the key if it is not present
vi .env
opschain server configure
opschain server deploy
```

### Project/environment

The global retention setting can be overridden by creating a `change_log_retention_days` or a `event_retention_days` config property within the project or environment properties. As with all properties, environment configuration values will override project configuration values.

Below is an example of setting this configuration via the [OpsChain properties](../../reference/concepts/properties.md):

```json
{
  "opschain": {
    "config": {
      "change_log_retention_days": 30,
      "event_retention_days": 7
    }
  },
  ...
}
```

Load the configuration into OpsChain using the `opschain project|environment set-properties` command.

The configuration can explicitly be set to `null` to disable log removal in this project or environment, overriding a higher level setting.

## Removal job configuration

The change log and event removal job runs daily by default.

The `OPSCHAIN_CLEAN_OLD_DATA_JOB_CRON` environment variable can be set in `.env` to change when/how the job runs.

For example, the removal job could be configured to only run on weekends as follows:

```bash
echo "OPSCHAIN_CLEAN_OLD_DATA_JOB_CRON='0 23 * * 6-7'" >> .env
opschain server configure
opschain server deploy
```

[crontab.guru](https://crontab.guru/) is a useful tool for creating cron rules.

Setting `OPSCHAIN_CLEAN_OLD_DATA_JOB_CRON=never` will prevent the log removal job from running.

## See also

The OpsChain log aggregator can be configured to forward change logs to external log storage. See the [OpsChain change log forwarding](../log_forwarding.md) guide for details.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
