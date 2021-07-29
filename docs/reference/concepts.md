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

A project Git repository is where you store the actions and related configuration to apply to the project's environments. OpsChain will read all action and resource definitions from the `actions.rb` file in the repository root directory.  See the [Actions Reference Guide](actions.md) and [Developing Your Own Resources](../developing_resources.md) guide for further information about the contents of the `actions.rb` file.

## Properties

See the [OpsChain Properties](properties.md) guide for more information on using OpsChain properties.

## Step

A step is a unit of work that is run by an OpsChain worker. A step typically runs a single action that may have its own prerequisites and child steps.

## Change

A change is the application of an action from a specific commit in the project's Git repository, to a particular project environment.  A step will be created for the change action, with additional steps created for each child action it requests.

## Controller

A controller is a ruby object that can be configured via properties and provides the logic for completing different actions. A controller class must have:
1. an `initialize` method that accepts a hash containing different properties.
2. one or more action methods (these do not accept parameters)

An example controller is shown in the [Actions Reference Guide](actions.md#controller).

# Licence & Authors
- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../../LICENCE)
