# Setting up automated changes

This guide takes you through creating automated changes in OpsChain.

After following this guide you should know:

- how automated change rules work
- how to create, list and delete automated change rules
- the basics of automated change rules

## Prerequisites

The CLI examples in this guide assume the steps from the [getting started](getting_started.md) have been run.

## About automated changes rules

Automated change rules are rules configured in OpsChain that will automatically create and deploy changes in an environment:

- at a particular time
- in response to project Git repository updates

The OpsChain CLI provides commands for interacting with automated change rules via the `opschain automated-change` command.

## Creating an automated change rule for new commits

Automated change rules can be used to create changes automatically in response to new commits to the project Git repository.

A new automated change rule can be created by using the `opschain automated-change create` subcommand in the CLI.

```bash
opschain automated-change create --project-code demo --environment-code dev --git-rev master --new-commits-only --action hello_world --cron-schedule '* * * * *' --repeat --confirm
```

This creates a new automated change rule that will create an OpsChain change to run the `hello_world` action whenever the `demo` project's Git repository's `master` branch changes.

_If the current commit that `master` points to hasn't been used in a change for the `hello_world` action in the `dev` environment then a new change will be created straight away as part of this automated change rule._

Follow the steps from the [adding a new action](getting_started.md#adding-a-new-action-optional) guide (or make a change to the existing `hello_world` action) to create the new commit for OpsChain to deploy.

Run the OpsChain change list command to list changes in this environment. _Note: it can take a minute for the OpsChain worker to detect the Git updates and create the new change_.

```bash
opschain automated-change list --project-code demo --environment-code dev
```

The output will now include a new change that has been created in response to our new Git commit.

As more commits are added to the Git repository, new changes will be created. Automated change rules poll the project's Git repository for new commits on the Git revision. If multiple commits occur on the relevant Git revision between polls then only one automated change will be created with the latest commit.

_Note that when referring to a remote branch, the remote name needs to be used as part of the Git revision for a change commit rule (eg `origin/master` rather than `master`)._

## Listing automated change rules in an environment

Automated change rules configured in an environment can be listed by using the `opschain automated-change list` subcommand in the CLI.

```bash
opschain automated-change list --project-code demo --environment-code dev
```

Take note of the ID shown as it will be used to delete the automated change rule.

## Deleting an automated change rule

Automated change rules can be deleted by using the `opschain automated-change delete` subcommand in the CLI.

```bash
opschain automated-change delete --automated-change-id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx --confirm
```

## Creating a scheduled automated change rule

Automated change rules can be scheduled to create changes at a certain time. They can also be configured to run only if new commits are present or not.

The following command creates a new automated change rule that will create a new change running the `hello_world` action daily at 7pm (based on the OpsChain server time).

```bash
opschain automated-change create --project-code demo --environment-code dev --git-rev master --new-commits-only=false --action hello_world --cron-schedule '0 19 * * *' --repeat --confirm
```

If the `--new-commits-only=false` were changed to `--new-commits-only=true` then the new change would only be created if new commits had been added to `master`. If the `--repeat` argument were changed to `--repeat=false` then a single new change would be created at 7pm and then the automated change rule would be deleted - the change would be created once rather than daily.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../LICENCE)
