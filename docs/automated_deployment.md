# Setting up an Automated Deployment

This guide takes you through creating an automated deployment in OpsChain.

After following this guide you should know:
- how automated change deployments work
- how to create, list and delete automated deployment rules
- the basics of scheduled deployment rules

## Prerequisites

This guide assumes the steps from the [Getting Started](getting_started.md) have been run.

## About Automated Deployments

Automated deployments are rules configured in OpsChain that, in response to project Git repository updates, will create and deploy changes in an environment.

Automated deployments poll the project's Git repository to find updates (changes to the Git ref) and automatically create a change when the relevant Git ref points to a different commit.

When an automated deployment rule is active for a project's Git repository, OpsChain will automatically fetch any Git remotes configured for the repository.

The OpsChain CLI provides commands for interacting with automated deployment rules as subcommands under the `opschain change` command.

## Creating an Automated Deployment Rule

A new automated deployment rule can be created by using the `opschain change automated-deployment-create` subcommand in the CLI.

```
opschain change automated-deployment-create --project_id $project_id --environment_code dev --ref master --action hello_world --confirm
```

This creates an automated change rule that will create an OpsChain change to run the `hello_world` action whenever the project's Git repository's `master` branch changes.

_If the current commit that `master` points to hasn't been used in a change for the `hello_world` action in the `dev` environment then a new change will be created straight away as part of this automated deployment rule._

Now that the automated deployment has been created the project Git repository needs to be updated such that the new automated deployment has something to run.

Follow the steps from the [Adding a New Action](getting_started.md#adding-a-new-action-optional) guide (or make a change to the existing `hello_world` action) to create the new commit for OpsChain to deploy.

Once the update has been committed to the project Git repository it can take a minute for the OpsChain worker to detect the Git updates and create the new change.

Once a minute or two has passed, run the OpsChain Change list command to list changes in this environment:

```
opschain change ls -p $project_id -e dev
```

The output will now include a new change that has been created in response to our new Git change. (The change may still be underway.)

As more and more commits are added to the Git repository new changes will be created. Automated deployments poll the project's Git repository to look for new commits on the Git ref, if more than one commit happens on the relevant ref between polls then only one automated change will be created with the latest commit.

_Note that when referring to a remote branch, the remote name needs to be used as part of the Git ref for an automated deployment (eg `origin/master` rather than `master`)._

## Listing Automated Deployments Rules in an Environment

Automated deployment rules configured in an environment can be listed by using the `opschain change automated-deployment-list` subcommand in the CLI.

```
opschain change automated-deployment-list --project_id $project_id --environment_code dev
```

This will show any automated deployments configured in the `dev` environment.

Take note of the ID shown as it will be used to delete the automated deployment.

## Deleting an Automated Deployment Rule in an Environment

Automated deployment rules can be deleted by using the `opschain change automated-deployment-delete` subcommand in the CLI.

```
opschain change automated-deployment-delete --automated_deployment_id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx --confirm
```

## Other Deployment Rules

### Scheduled Deployment Rules

Scheduled deployment rules are similar to automated deployment rules, however:
 - the time the change is created can be configured.
 - the change is created whether there are Git changes or not.
 - the rule may optionally be configured to repeat automatically.

Scheduled deployment rules are configured using the `scheduled-deployment-create`, `scheduled-deployment-delete` and `scheduled-deployment-list` commands.

The pattern of interaction is the same as `automated-deployment-create`, `automated-deployment-delete` and `automated-deployment-list` however the creation arguments vary.

Running `opschain change automated-deployment-create --help` will show details of the scheduled deployment rule configuration arguments.

## What to Do Next

Try creating a scheduled deployment rule by following the same concepts demonstrated in this guide.

# Licence & Authors
- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../LICENCE)
