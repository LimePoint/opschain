# Developing Your Own Resources

Resources and the Resource Types are the building blocks for OpsChain changes. After following this guide you should understand:
- the relationship between resources, resource types, controllers and actions.
- how to use the OpsChain logger to assist with resource development
- how to create your own custom step runner Dockerfiles

_Note: Iterating on resource type, resource and action definitions is made easier by using the [Docker Development Environment](docker_development_environment.md)_

## Develop a Resource Controller

The bulk of the logic for your resource should be enclosed within a [controller](reference/concepts.md#controller) class. This simplifies unit testing and reduces complexity in `resource_types.rb`.

Notes:
* The class constructor must accept a single [Ruby hash](https://ruby-doc.org/core-2.7.0/Hash.html) parameter, which will include each of the resource properties defined on the resource.
* The action methods must not require parameters.

Example controllers can be seen in the [Actions Reference Guide](reference/actions.md#controller) and within the [Confluent OpsChain Example Project](https://github.com/LimePoint/opschain-examples-confluent).

## Define a Resource Type

Once the controller class has been written and tested, define your [resource type](reference/concepts.md#resource-type), referencing your custom controller class. Use the `action_methods` keyword to create actions for those controller methods that do not require pre or post requisite actions (see [Defining Standalone Actions](reference/actions.md#defining-standalone-actions) for more details)

_Note: Resource Types are commonly stored in `resource_types.rb` but can be included in any file that is required by your `actions.rb`_

### Define Resource Properties

Ensure you define a resource property for each hash key your controller class is expecting in its constructor. (See the [controller](reference/concepts.md#controller) example in the Reference Guide)

### Define Additional Resource Actions

If your action(s) have pre or post requisite actions, define the actions within the resource type itself (see the [Actions Reference Guide](reference/actions.md) for information on creating actions).

For example the following code creates a `database` resource type with four actions: `copy_installer`, `install_and_startup`, `startup` and `shutdown`.

```ruby
require 'database_controller'

resource_type :database do
  controller DatabaseController, action_methods: [:copy_installer, :startup, :shutdown]
  property :host
  property :source_path

  action install_and_startup: [:copy_installer], steps: [:startup] |type|
    type.controller.install
  end
end
```

The `install_and_startup` action will:
1. execute the `copy_installer` pre-requisite action (to execute the `copy_installer` controller method)
2. execute the `install` controller method (manually called from within the action body)
3. request the `startup` action be run as a child step (to execute the `startup` controller method).

## Define a Resource

Once the resource type has been defined, use this in your `actions.rb` file to create a [resource](reference/concepts.md#resource). For example the following `actions.rb` file will create a `my_database` resource, with the four actions defined in the type:

```ruby
require 'resource_types'

database :my_database do
  host 'localhost'
  source_path '/var/tmp/db_installer.sh'
end
```

_Note: Based on the type and resource definitions above, the DatabaseController instance for `my_database` will be constructed as follows:_

```ruby
DatabaseController.new(
  host: 'localhost',
  source_path: '/var/tmp/db_installer.sh'
)
```

## OpsChain Logger

The OpsChain logger is a standard Ruby Logger object. By default the logger is configured to log all INFO severity (and higher) messages to STDOUT. You can use the OpsChain logger from anywhere in your `actions.rb` or project code:

```ruby
require 'opschain'

OpsChain.logger.info "Informational message"
OpsChain.logger.warn "Warning message"
OpsChain.logger.error "Error message"
OpsChain.logger.fatal "Fatal message"
```

If required, the logger can be set to also display DEBUG level messages as follows:

```ruby
OpsChain.logger.level = ::Logger::DEBUG
OpsChain.logger.debug "Debug message"
```

## Custom Step Runner Dockerfiles

If your resource requires external packages, you will need to include a [Custom Step Runner Dockerfile](reference/actions.md#custom-step-runner-dockerfiles) in your project Git repository. This will allow you to include the required software on the OpsChain Step Runner container running your change.

### Creating a Custom Step Runner Dockerfile

OpsChain provides a template for the Step Runner image Dockerfile which is the same as the Dockerfile used by OpsChain to build the default Step Runner image.

Run the following steps from the `opschain-release` directory to add the Dockerfile template to your repository.

1. Change into your project directory using the Project ID:

    ```
    $ cd opschain_data/opschain_project_git_repos/<project code>
    ```
_Note: The path above assumes the default `opschain_data` path was accepted when you ran `configure` - adapt the path as necessary based on your configuration._

2. Create the `.opschain` directory the Dockerfile will reside in:

    ```
    $ mkdir -p .opschain
    ```

3. Use the `opschain-utils` script to output the template into the Dockerfile:

    ```
    $ opschain-utils dockerfile_template > .opschain/Dockerfile
    ```

4. You can now make any modifications to the Dockerfile you desire (See the [Supported Customisations](reference/actions.md#supported-customisations) section of the Reference Guide for more information).

5. Add and commit the Dockerfile:

    ```
    $ git add .opschain/Dockerfile
    $ git commit -m "Adding a custom Dockerfile."
    ```

When running your Steps OpsChain will now use this Dockerfile when running changes.

_Note: Commits before this point won't use the custom Dockerfile because it is not present._



## Licence & Authors
- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../LICENCE)
