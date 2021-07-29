# Actions reference guide

This guide covers how to develop standalone and resource specific actions, how they integrate with the API server and options for utilising additional packages that are not in the standard OpsChain runner container.

After reading this guide you should understand:

- how to define
  - resource types
  - resources
  - standalone and resource specific actions
  - composite resource types and resources
- how the API server and step runner exchange critical information
- how to create and use a custom step runner Docker container

## Defining standalone actions

Actions are defined in the `actions.rb` file in the root directory of the project Git repository. If required, actions can also be defined in separate files and [required](https://www.rubydoc.info/stdlib/core/Kernel%3Arequire) into the `actions.rb`.

The `action` definition extends the Rake `task` definition, so standard [Rake features](https://ruby.github.io/rake/) can be used.

An action can have __prerequisites__ that will run before the body of the action is run. These behave like standard [Rake prerequisites](https://ruby.github.io/rake/doc/rakefile_rdoc.html#label-Tasks+with+Prerequisites).

```ruby
require 'opschain'

action do_something: [:do_something_before, :do_something_else_before] do
  # this will run after prerequisites
end

action :do_something_before do
  # runs before do_something
end

action :do_something_else_before do
  # runs before do_something
end
```

In the above example actions would run in this order:

1. `do_something_before`
2. `do_something_else_before`
3. `do_something`

An action can also have __steps__ that will run after the body of the action has run. Each step will be assigned to an OpsChain worker when one becomes available and run in a new OpsChain runner instance.

```ruby
require 'opschain'

action do_something: steps: [:do_something_after, :do_something_else_after] do
  # this will run before steps
end

action :do_something_after do
  # runs after do_something
end

action :do_something_else_after do
  # runs after do_something_after
end
```

In the above example actions would run in this order:

1. `do_something`
2. `do_something_after`
3. `do_something_else_after`

By default the steps defined will run sequentially across the OpsChain workers. The steps will be run in parallel if `:parallel` is provided for the `run_as` option (the default is `:sequential`, ie one at a time in the order defined). Parallel tasks are limited by the number of available OpsChain workers:

```ruby
require 'opschain'

action do_something: steps: [:do_something_after, :do_something_else_after], run_as: :parallel do
  # this will run before steps
end

action :do_something_after do
  # runs after do_something
end

action :do_something_else_after do
  # runs at the same time as do_something_after (providing there is a free worker)
end
```

In the above example actions would run in this order:

1. `do_something`
2. `do_something_after` and `do_something_else_after`

Defining an action bodies:

```ruby
require 'opschain'

action :say_hello do
  puts 'First hello'
end

action :say_hello do
  puts 'Second hello'
end
```

Running the `say_hello` action as it is defined above would produce the following output:

```text
First hello
Second hello
```

Note: Current limitations:

- Any `action` steps defined by subsequent steps will not be discovered upfront and hence not visible via the OpsChain CLI until the parent step is executed.
- Steps defined on a parent task will override any steps defined on any dependent tasks.
- In order for a step (and subsequently the change) status to be set to 'error', the `action` must raise an `Exception`.

## Defining resource types & resources

Resource types can be defined using the `resource_type` keyword:

```ruby
resource_type :city do
  property :name
  property :weather

  action :report_weather do |action|
    puts "The weather in #{action.resource_properties.name} looks #{action.resource_properties.weather}"
  end
end
```

The `city` resource type can now be used to create `city` resources:

```ruby
city :melbourne do
  name 'Melbourne'
  weather 'cold'
end
```

These resources will automatically include the `name` and `weather` properties, as well as a `report_weather` action. In this example a `melbourne` resource will be created with a `melbourne:report_weather` action. Running this action will output:

`The weather in Melbourne looks cold`

### Controller

Defining inline actions as in the example above limits your ability to adequately test the action code. Moving the code into a controller class allows the code to more readily be tested and reduces the need to change your resource type definition to change its action logic.

Re-writing the example above to make use of a controller simplifies the resource type definition:

```ruby
class CityController
  attr_reader :name, :weather

  def initialize(options)
    @name = options[:name]
    @weather = options[:weather]
  end

  def report_weather
    puts "The weather in #{name} looks #{weather}"
  end
end

resource_type :city do
  controller CityController, action_methods: [:report_weather]
  property :name
  property :weather
end
```

_Note: the `action_methods` keyword will automatically expose each controller method supplied to it as an action on the resource._

Resources created from this `city` resource type would have the same actions (and same action output) as those created from the earlier type definition.

#### Controller actions and properties

Controllers can define the `resource_type_actions` and/or `resource_type_properties` class methods to expose their default actions and properties to OpsChain. Using these methods, the example above could be re-written as:

```ruby
class CityController
  attr_reader :name, :weather

  def self.resource_type_properties
    %i[name weather]
  end

  def self.resource_type_actions
    %i[report_weather]
  end

  def initialize(options)
    @name = options[:name]
    @weather = options[:weather]
  end

  def report_weather
    puts "The weather in #{name} looks #{weather}"
  end
end

resource_type :city do
  controller CityController
end
```

Once again, resources created from this `city` resource type would have the same actions (and same action output) as those created from the earlier type definitions.

_Note: If you supply the `action_methods:` parameter when defining the resource type's controller, the controller's `resource_type_actions` will be ignored and only those methods passed to `action_methods:` will be exposed._

_Note: At the beginning of each step, the merged project and environment properties are used to initialize each resource type's controller. Any changes made to the OpsChain environment or project properties during a step will be available in the controller in subsequent steps but will not be reflected in the controller in the current step. If required, the relevant controller's setter method can be called directly to change the value._

### Defining resource type actions

Any combination of controller actions and locally defined actions can be used within a Resource or Resource Type.

```ruby
resource_type :city do
  controller CityController

  action :send_postcard do |action|
    puts "Sending postcard from #{action.controller.name}"
  end
end
```

Using this `city` resource type, resources will include the `report_weather` and `send_postcard` actions.

_Note: In the initial resource type example (without a controller), the city name was retrieved from `action.resource_properties.name`. With a controller supplied, the property values are passed through to the controller, hence `action.controller.name` is used above._

_Note: If you define a resource type action with the same name as a controller action_method, OpsChain will run the controller action, then the resource_type action._

### Using namespaces to separate resources and actions

You can nest namespaces to organise your resources. Namespaces also allow the same resource name to be used multiple times. You can open the same namespace multiple times and the results will be combined:

```ruby
namespace :earth do
  namespace :australia do
    city :perth do
      name 'Perth'
      weather 'sunny'
    end
  end

  namespace :scotland do
    city :perth do
      name 'Perth'
      weather 'gloomy'
    end
  end
end

namespace :earth do
  namespace :australia do
    city :sydney do
      name 'Sydney'
      weather 'nice'
    end
  end
end
```

This would define the following actions:

- `earth:australia:perth:report_weather`
- `earth:australia:perth:send_postcard`
- `earth:australia:sydney:report_weather`
- `earth:australia:sydney:send_postcard`
- `earth:scotland:perth:report_weather`
- `earth:scotland:perth:send_postcard`

### Referencing previous resources

Resources previously defined within the same namespace can be referenced from other resource definitions:

```ruby
namespace :australia do
  city :sydney do
    name 'Sydney'
    weather 'nice'
  end

  city :melbourne do
    name 'Melbourne'
    rival sydney
  end
end
```

If a resource is referenced, its controller will be set as the property value. In the example above `melbourne.rival` would be set to the `CityController` instance linked to the `sydney` resource. A `melbourne` action could then reference `rival.name` to utilise the `attr_reader` for the `name` variable in the `sydney` resource's `CityController` instance.

_Note: Setting the resource property to be the result of `property_value.controller` if `property_value` responds to `controller` is the default behaviour._

### Setting multiple properties

Multiple resource properties can be assigned values in a single step by taking advantage of the [OpsChain properties](properties.md) feature. Assuming the OpsChain properties JSON was set to:

```json
{
  "melbourne_resource": {
    "name": "Melbourne",
    "weather": "cold"
  }
}
```

The `melbourne` city resource could be created as follows:

```ruby
city :melbourne do
  properties OpsChain.properties.melbourne_resource
end
```

If the dynamic nature of [OpsChain properties](properties.md) is not required, you can directly supply a hash containing the property values, keyed with their property names.

```ruby
city :melbourne do
  properties { name: 'Melbourne', weather: 'cold' }
end
```

#### Property setting override behaviour

Any combination of individually set properties and calls to `properties` can be used to construct the final set of values used to construct the resource's controller. The set of properties used will follow this behaviour:

- successive calls to `properties` will deep merge into any previously set via that method
- individually set properties will override any set via `properties`
- successive calls to set an individual property will override any previous values set

```ruby
first_props = {
  name: {
    a: 'complex value'
  },
  weather: {
    temp: 'a bit cold',
    wind: 'a bit'
  }
}

second_props = {
  weather: {
    temp: 'ok'
  }
}

city :melbourne do
  name 'coffee capital'
  name 'Melbs'

  properties first_props
  properties second_props
end
```

The above example would result in the creation of a controller with these properties:

```ruby
{
  name: 'Melbs',
  weather: {
    temp: 'ok',
    wind: 'a bit'
  }
}
```

## Defining resource actions

In addition to controller actions and resource type actions, you can also define actions specific to an individual resource:

```ruby
city :melbourne do
  name 'Melbourne'

  action :welcome do |action|
    puts "Welcome to #{action.controller.name}"
  end
end
```

These actions can have prerequisites and initiate subsequent steps like normal actions however you must refer to them using the fully qualified action name:

```ruby
city :melbourne do
  name 'Melbourne'

  action :get_coffee do
    puts 'getting coffee'
  end

  action :see_music do
    puts 'seeing music'
  end

  action :visit, steps: ['melbourne:get_coffee', 'melbourne:see_music']
end
```

Any actions defined within a resource will run __after__ controller and resource type actions with the same name.

## Defining composite resources & resource types

You can define a composite resource that manages child resources.

- `children` specifies the keys and values to be iterated over, it is supplied when creating a resource.
- `each_child` defines a namespace for each child and defines a copy of any configured actions and resources in that namespace.
- `child_actions` can be used to reference the actions of each child. This is useful for actions defined at the parent composite resource (or resource type) level that may want to reference these child actions as steps.

These can be used in a resource definition to create child resources specific to that resource. More commonly, they can be used in a resource type definition to create child resources for each resource of this type.

```ruby
suburb_properties = {
  richmond: {
    team: 'tigers'
  },
  collingwood: {
    team: 'magpies'
  }
}

resource_type :team

resource_type :city do
  each_child do |suburb, properties|
    team :local_team do
      properties properties
      action :barrack do |a|
        puts "Go #{suburb} #{a.resource_properties[:team]}!"
      end
    end
  end

  action :barrack_all, steps: child_actions('local_team:barrack')
end

city :melbourne do
  children suburb_properties
end
```

This would define the following actions:

- `melbourne:richmond:local_team:barrack`
- `melbourne:collingwood:local_team:barrack`
- `melbourne:barrack_all`

## API - step runner integration

Each step in an OpsChain change is executed inside an OpsChain step runner Docker container. When building the runner, OpsChain includes:

1. the project's Git repository, reset to the requested revision, in the `/opt/opschain` directory.
2. the project and environment [properties](properties.md) to be used by the step, in the `/opt/opschain/.opschain/step_context.json` file.

Upon completion, the step will produce a `/opt/opschain/.opschain/step_result.json` file to be processed by the API server, detailing:

1. any changes to the project and environment [properties](properties.md) the action has performed
2. the merged set of properties used by the action
3. any child steps the action requires to be scheduled (and their execution strategy).

### Step context JSON

#### File structure

The `step_context.json` file has the following structure:

```text
{
  "context": {
    "project": {
      "code": "demo",
      "name": "Demo Project",
      ...
    },
    "environment": ...
    "change": ...
    "step": ...,
    "user": ...
  },
  "project": {
    "properties": {
      "project_property": "value",
      "files": {
        "sample-file": {
          "path": "/path/to/file.txt",
          "mode": "0600",
          "content": "contents of the file"
        }
      },
      "env": {
        "VARIABLE_NAME": "variable value"
      }
    }
  },
  "environment": {
    "properties": {
      "environment_property": "value",
      "files": {
        "different-file": {
          "path": "/path/to/another_file.txt",
          "mode": "0600",
          "content": "contents of the file"
        }
      },
      "env": {
        "VARIABLE_NAME": "variable value"
      }
    }
  }
}
```

#### File content - step context

The `context` values are derived from the current step. The [OpsChain context guide](context.md) provides more details on the values available.

The `project/properties` value is the output from `$ opschain project properties-show --project-code <project code>`.

The `environment/properties` value is the output from `$ opschain environment properties-show --project-code <project code> --environment-code <environment code>`

_Replace the `<project code>` and `<environment code>` in the commands above with the values for the project and environment related to the change._

### Step result JSON

The `step_result.json` file has the following structure:

```json
{
  "project": {
    "properties_diff": [
      {
        "op": "add",
        "path": "/new_element",
        "value": "test_value"
      }
    ]
  },
  "environment": {
    "properties_diff": []
  },
  "step": {
    "properties": {
      "opschain": {}
    }
  },
  "steps": {
    "children": [
      {
        "action": "sample:hello_world_1:run"
      }
    ],
    "child_execution_strategy": null
  }
}
```

#### File content - step result

The `project/properties_diff` and `environment/properties_diff` values contain [RFC6902](http://www.rfc-editor.org/rfc/rfc6902.txt) JSON Patch values, describing the changes to apply to the project or environment properties.

The `step/properties` contains the merged set of properties applied to the action. These are linked to the step to support future investigation / debugging.

The `steps/children` value contains the child steps (and execution strategy) the OpsChain workers will execute.

## Custom step runner Dockerfiles

### Overview

OpsChain runs all steps using Docker containers. By default these containers use a Centos-based image that provides the MintPress Controller Gems with an associated Ruby installation and the standard Centos base development tooling. The image used by the step container is built as part of every step's execution and relies on Docker build caching functionality to keep this performant.

If your resources or actions rely on external software the image used for these containers can be modified to add extra packages or executables. The image may also be modified to optimise the performance of build steps by performing tasks as part of the step image build rather than as part of the step execution.

_Please Note: The `opschain-action`/`opschain-dev` scripts do not currently support using a custom Dockerfile. A [workaround](../troubleshooting.md#customising-the-opschain-development-environment) may assist with developing / testing resources that require additional packages._

### Dockerfile location

To have your project actions run in a custom step runner container, create the Dockerfile for the container in the `.opschain` directory of the OpsChain project's Git repository as `.opschain/Dockerfile`.

This Dockerfile is used from the commit that the change refers to - so the OpsChain step runner Docker image could be different for different Commits.

### Customising the Dockerfile

This Dockerfile can be modified and committed like any other file in the project Git repository.

NB. If you no longer wish to use a custom Dockerfile then `.opschain/Dockerfile` can be removed from the project repository.

The image is built in a Docker build context with access to the following files:

- `repo.tar` - The complete project Git repository including the .git directory with all commit info.
  This file will change (and invalidate the build context) when a different commit is used for a change or when there are changes to the project's Git repository.
- `step_context_env.json` - The environment variables for the project and environment for use by `opschain-exec`.
  This file will change if the environment variables in the project or environment [properties](properties.md) change.

The [Dockerfile reference](https://docs.docker.com/engine/reference/builder/) and the [best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/) guide provide more information about writing Dockerfiles.

OpsChain uses [BuildKit](https://docs.docker.com/develop/develop-images/build_enhancements/) when building the step image.

### Supported customisations

Modifying the Dockerfile allows a lot of flexibility.

For maximum compatibility with the OpsChain tool we suggest only using the Dockerfile `RUN`, `COPY`, `ENV`, and `ADD` commands.

More advanced modifications (like modifying the `ENTRYPOINT`) may break OpsChain and are not supported.

Custom Dockerfiles must use the `limepoint/opschain-runner` image as a base (ie `FROM limepoint/opschain-runner`).

### Image performance - base images

OpsChain runs a Docker build for every step within a change.

This is normally performant due to Docker's image build cache - however it is possible to prebuild a custom base image if desired. This may make the image build faster when run for each step.

A custom base image can be created as follows:

1. Create a Dockerfile for the base image which uses `FROM limepoint/opschain-runner`.

    ```
    FROM limepoint/opschain-runner

    # run your custom Docker build commands like any Dockerfile
    # Note: the OpsChain Docker build context files will not be available here
    ```

2. Build and distribute the base image, assigning it a unique tag (the `my-base-image` used below is for example purposes only).

    ```bash
    docker build -t my-base-image .
    ```

3. Use the custom base image in the project custom Dockerfile.

    ```
    FROM my-base-image # supply the tag used above

    ... # the rest of the OpsChain custom Dockerfile
    ```

4. Run your change as normal. It will now use the `my-base-image` image as the base for the custom step image.

OpsChain relies on configuration done as part of the `limepoint/opschain-runner` base image to work. By basing the custom base image on `limepoint/opschain-runner` the OpsChain configuration still applies and will work as desired.

[Contact us](mailto:opschain@limepoint.com) if you would like to express your interest in this feature.

## What to do next

Learn about the [Docker development environment](../docker_development_environment.md).
Try [developing your own resources](../developing_resources.md).

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../../LICENCE)
