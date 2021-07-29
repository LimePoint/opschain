# OpsChain Concepts

Introduces various concepts that will help you to understand the tool and its uses.

## Project

Projects are used to organise environments and changes and are analogous to [JIRA projects](https://support.atlassian.com/jira-software-cloud/docs/what-is-a-jira-software-project/). Each project has
* a Git repository containing configuration for that project.
* [properties](properties.md) where you can store project specific:
  * key value pairs
  * environment variables and values (that will be available in the Unix environment running a change action)
  * files (that will be written to the working directory before running a change action).

## Environment

Environments represent the logical infrastructure environments under a project (for example Development or Production). Environments also have an associated set of encrypted [properties](properties.md). If a property exists at project and environment level, the environment value will override the project value.

## Action

An action is a task that can be performed (for example provisioning or restarting a server). Actions can have prerequisites that will run before and steps that will run after the main action has completed.

The logic for an action can be provided directly within the action definition, or if the action forms part of a Resource, it can call logic within its associated controller.

See the [Actions Reference Guide](actions.md#defining-standalone-actions) and [Developing Your Own Resources](../developing_resources.md) guide for more information.

## Resource

A resource represents something that OpsChain can perform actions on (eg. SOA Instance, Confluent Broker, Linux Host, etc.) and is an instance of a resource type. A resource may include:
* A controller class that will provide logic for some (or all) of the resource actions.
* Any number of resource properties. These are key value pairs that can be referenced in the action code and are supplied as a hash to the controller's constructor.
* Any number of action definitions, allowing you to define actions that can be performed on the resource.

See the [Actions Reference Guide](actions.md#defining-resource-types--resources) and [Developing Your Own Resources](../developing_resources.md) guide for more information.

## Resource Type

A resource type is a template for creating resources. Rather than duplicating the definition for each instance of a resource, the controller, resource properties and action definitions can be defined in the resource type and automatically configured when the resource is created.

See the [Actions Reference Guide](actions.md#defining-resource-types--resources) and [Developing Your Own Resources](../developing_resources.md) guide for more information.

## Composite Resource

A composite resource is a resource that encapsulates child resources. An example of this is the confluent broker composite defined in the [resource types](https://github.com/LimePoint/opschain-examples-confluent/blob/master/lib/confluent/resource_types.rb) used in the [Confluent Example](../running_a_complex_change.md). The confluent broker composite provides the definition of the resources required to create one or more child brokers. Each broker will have a host, java installation, confluent installation and broker definition.

Composite resources also allow you to define actions that will apply to all the composite's children. The confluent broker composite in the example defines three actions (configure, start and install). Executing any of these actions on the composite will execute the equivalent action on each of the child brokers.

See the [Actions Reference Guide](actions.md#defining-composite-resources--resource-types) and [Developing Your Own Resources](../developing_resources.md) guide for more information.

## Project Git Repository

See the [OpsChain Project Git Repositories](project_git_repositories.md) guide for more information.

## Properties

See the [OpsChain Properties](properties.md) guide for more information.

## Step

A step is a unit of work that is run by an OpsChain worker. A step typically runs a single action that may have its own prerequisites and child steps.

## Change

A change is the application of an action from a specific commit in the project's Git repository, to a particular project environment. A step will be created for the change action, with additional steps created for each child action it requests.

Only one change can be running in an environment at a time. Changes will sit in the `pending` state whilst waiting for the existing change to finish.

### Change & Step lifecycle

Changes, and the steps that make them up, transition between states as they execute.

Changes are created in the `pending` state and are in this state until they start execution. A change stays in the `pending` state while waiting for any existing changes in the same environment to finish. A step stays in the `pending` state until its prerequisites are complete. If a prerequisite step fails any dependent steps will remain in the `pending` state and will not transition further.

When a change starts executing it enters the `queued` state. Changes and steps stay in the `queued` state while they are waiting for an OpsChain worker to start executing them (e.g. if all workers are already busy).

Whilst a change or step is actively executing it is in the `running` state.

If the change/step succeeds it transitions to the `success` state. If the change/step fails it transitions to the `error` state.

If a change is cancelled by a user all finalised steps (i.e. in the `success` or `error` state) remain in their existing state, and all `pending`, `queued`, or `running` steps are transitioned to the `cancelled` state. There is no rollback of any kind, steps that have not yet started will not start, and steps that are in progress are stopped immediately.

## Automated Change Rule

An automated change rule allows the automated creation and execution of a change.

They exist to facilitate [automated deployments](#automated-deployment) and in the future will enable scheduled deployments.

### Automated Deployment

An automated deployment is a type of [automated change rule](#automated-change-rule) that creates a change in a particular environment in response to changes in a project's Git repository.

Automated deployments mean that OpsChain will poll the project Git repository looking for new commits and will create a new change in the targeted environment if a Git ref changes in the project's Git repository.

See [Setting up an Automated Deployment](../automated_deployment.md) for a guide on how to create an automated deployment.

### Scheduled Deployment

A scheduled deployment is a type of [automated change rule](#automated-change-rule) that creates a change in a particular environment based on a [cron schedule](https://crontab.guru/). The cron schedule supports the [fugit cron format](https://github.com/floraison/fugit#fugitcron).

Scheduled deployment rules support optional repetition.

See the [Scheduled Deployment Rules](../automated_deployment.md#scheduled-deployment-rules) section of the [Setting up an Automated Deployment](../automated_deployment.md) guide to learn more.

## Controller

A controller is a ruby object that can be configured via properties and provides the logic for completing different actions. A controller class must have:
1. an `initialize` method that accepts a hash containing different properties.
2. one or more action methods (these do not accept parameters)

An example controller is shown in the [Actions Reference Guide](actions.md#controller).

## Licence & Authors
- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../../LICENCE)
