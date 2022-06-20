# Actions reference guide

This guide covers how to develop standalone and resource specific actions, how they integrate with the API server and options for utilising additional packages that are not in the standard OpsChain runner container.

After reading this guide you should understand:

- how to define
  - actions
  - controllers
  - resource types
  - resources
  - resource actions
  - composite resource types and resources
- how to use the OpsChain logger

_This reference guide covers concepts from the [developer getting started guide](../../getting_started/developer.md) in more depth. If this is your first experience developing with OpsChain it may be a better place to start._

## Defining standalone actions

Actions are defined in the `actions.rb` file in the root directory of the project Git repository. If required, actions can also be defined in separate files and [required](https://www.rubydoc.info/stdlib/core/Kernel%3Arequire) into the `actions.rb`.

The `action` definition extends the Rake `task` definition, so standard [Rake features](https://ruby.github.io/rake/) can be used. In its simplest form, an action requires a name, and the instructions to perform when it is executed (between the `do` and `end` keywords). The term "block" will be used to describe these instructions throughout the OpsChain documentation.

```ruby
require 'opschain'

action :hello_world do
  OpsChain.logger.info "hello world!"
end
```

In the example above, the action's name is `hello_world`, and the action's block instructs OpsChain to log "hello world" as an informational message (see [OpsChain Logger](#opschain-logger) for more information on using OpsChain's logger).

_Note: You must `require 'opschain'` at the top of your `actions.rb` file to allow you to use the features described in this reference guide._

## Sequencing actions

In addition to the action name, OpsChain's DSL allows you specify [prerequisite actions](#prerequisite-actions) (to run before the action's block) and [child steps](#child-steps) (to run after the action's block). In this way you can describe a sequence of actions to perform.

### Prerequisite actions

Prerequisite actions will run in the same [step runner](step_runner.md) as the requested action. These behave like standard [Rake prerequisites](https://ruby.github.io/rake/doc/rakefile_rdoc.html#label-Tasks+with+Prerequisites).

```ruby
action go_to_work: ['wake_up', 'get_dressed'] do
  # this optional block will run after get_dressed
end

action :wake_up do
  # this block will run before get_dressed
end

action :get_dressed do
  # this block will run after wake_up
end
```

In the example above, all actions would run in the same [step runner](step_runner.md), in this order:

1. `wake_up`
2. `get_dressed`
3. `go_to_work`

#### Combining actions on a single step runner

As noted in the prerequisite actions example above, an action with prerequisites (or [child steps](#child-steps)) need not include a block and can be specified as:

```ruby
action holiday: ['wake_up', 'get_dressed']
```

Running the `holiday` action will execute the `wake_up` and `get_dressed` actions in a single [step runner](step_runner.md).

Grouping actions on a single step runner comes with some advantages and disadvantages:

##### Advantages

1. Improved performance - as there is an overhead to building and launching each [step runner](step_runner.md), grouping actions can improve overall change performance
2. De-isolation - passing data between actions running in their own [step runners](step_runner.md) requires you to store the data in OpsChain's [properties](properties.md) (or in a data store accessible to both runners). Grouping actions on a single [step runner](step_runner.md) means the actions have access to the same file system and memory. This removes the need to store sensitive (or single use) information in [properties](properties.md)

##### Disadvantages

1. Execution visibility - prerequisite steps are not displayed in OpsChain's change step tree. This reduces the visibility of their start and stop times, making it harder to follow the change's progress. Similarly, when viewing the change logs, there is no separator in the logs between each prerequisite action's log messages nor with the grouping action's log messages (if any)
2. De-isolation - While it can be an advantage (as described above), care must be taken when deciding to combine actions on a single [step runner](step_runner.md). The modifications to the file system or memory that one action makes may have unintended effects if subsequent actions have been designed with an expectation that they will run in a "clean" [step runner](step_runner.md)

### Child steps

An action definition can include a list of other actions to run as child `steps`. After the parent's block has completed, these child steps will be added to the queue of actions to run. When an OpsChain worker becomes available, it will build and launch a [step runner](step_runner.md) to run the next action in the queue.

The `steps:` argument accepts:

1. A single action name - e.g. `steps: 'the_next_step'`
2. A list of actions - e.g. `steps: ['first_child', 'second_child']`
3. A Ruby method/proc that returns a single or list of actions - e.g. `steps: generate_step_list`

Actions can be specified as strings or Ruby symbols.

```ruby
action :do_something, steps: ['do_something_after', :do_something_else_after] do
  # this will run before steps
end

action :do_something_after do
  # runs after do_something and before do_something_else_after
end

action :do_something_else_after do
  # runs after do_something_after
end
```

In the example above each action will run in its own [step runner](step_runner.md), in this order:

1. `do_something`
2. `do_something_after`
3. `do_something_else_after`

#### Wait steps

An OpsChain wait step can be used to make an OpsChain change pause at a step and wait for a user to continue the change.

This can be useful to allow for manual verification after some steps have completed, but before subsequent steps start. It also allows a user to undertake manual activities as part of a change - for example steps that can't be automated.

An OpsChain wait step can only be added as part of a step's child steps, for example:

```ruby
action :do_something, steps: [:do_something_before_waiting, OpsChain.wait_step, :do_something_else_after_waiting]
```

Another useful scenario for wait steps is when an [automated change rule](automated_changes.md) is used to create a change automatically, but a team member should then allow the change to proceed manually. To achieve this the OpsChain wait step can be used as the first child step of an action:

```ruby
action :do_something, steps: [:do_something_after] do
  # this will run before steps
end

action :do_something_with_acknowledgement, steps: [OpsChain.wait_step, :do_something]
```

_Note: all the sibling steps of a wait step will run immediately when using `run_as: :parallel` - the change will not continue on subsequently until it is manually continued. See the [troubleshooting guide](/docs/troubleshooting.md#opschain-change-parallel-steps-run-before-wait-step) for more info._

The `opschain change continue` command can be used to continue a waiting change. Currently the `opschain change continue` command will continue all waiting steps for a change. The `/steps/{{step_id}}/continue` API endpoint can be used to continue a specific step, for example: `curl -X POST -u {{username}}:{{password}} localhost:3000/steps/{{step_id}}/continue`. See the [OpsChain REST API documentation](/docs/getting_started/README.md#review-the-rest-api-documentation) to learn more.

_Note: OpsChain wait steps use the naming convention `opschain_wait_step_{{unique id}}` - do not use this naming convention in your steps unless you intend to create an OpsChain wait step._

##### Step continuation auditing

Information about step continuation can be viewed by using the [events endpoint](events.md). The continue action will be recorded with the type `api:steps:continue` (these can be fetched via the API by requesting `/events?filter[type_eq]=api:steps:continue`). The username of the user who continued the step is available in the API response.

Please [let us know](mailto:opschain-support@limepoint.com) if you would like to suggest improvements in this area.

#### Dynamic child steps

OpsChain allows you to dynamically alter a parent's child steps from within the action's block.

_Notes:_

- _The step tree displayed by the CLI when running a change will not reflect dynamic child steps until the parent action executes_
- _the `append_child_steps` and `replace_child_steps` methods accept any value that can be supplied via the `steps:` argument when defining an action (see the valid argument values under [child steps](#child-steps))_

##### Append child steps

The `append_child_steps` method allows you to append additional children into the queue of steps the OpsChain workers will process. E.g.

```ruby
action :do_something, steps: 'do_something_after' do
  if Time.now.strftime("%a") == 'Tue'
    OpsChain.append_child_steps('do_something_on_tuesdays')
  end
end

action :do_something_after do
  # runs after do_something
end

action :do_something_on_tuesdays do
  # runs after do_something_after - on Tuesdays
  OpsChain.logger.info "It's Tuesday!"
end
```

In the example above actions would run in this order:

1. `do_something`
2. `do_something_after`
3. `do_something_on_tuesdays` (if the change is run on a Tuesday)

##### Replace child steps

If you wish to replace the list of child steps, it can be overwritten by assigning the new value(s) to `OpsChain.child_steps`. E.g.

```ruby
action :replace_child_steps, steps: ['do_something_after', 'do_something_else'] do
  OpsChain.child_steps = ['do_a_different_thing', 'do_another_thing']
end
```

In the example above actions would run in this order:

1. `replace_child_steps`
2. `do_a_different_thing`
3. `do_another_thing`

_Note: Care must be taken when directly modifying the `child_steps` value, as this will override all standard OpsChain step handling functionality for the current step runner and may have unintended consequences._

##### Accessing child steps

OpsChain stores the list of actions to run in child steps as a [Set](https://ruby-doc.org/stdlib/libdoc/set/rdoc/Set.html). It is available from within your action blocks via `OpsChain.child_steps`. E.g.

```ruby
action check_for_child_step: ['prereq_with_conditional_step'] do
  if OpsChain.child_steps.include?('conditional_step')
    OpsChain.logger.info '"prereq_with_conditional_step" added "conditional_step" to the child steps'
  end
end
```

In the example above, `check_for_child_step` will log an informational message if the `prereq_with_conditional_step` prerequisite has added the `conditional_step` action into the child steps of `check_for_child_step`

_Note: Modifying the child steps list via any method other than the append and replace methods described above is not supported._

### Child execution strategy

The action definition includes an optional `run_as:` parameter. By default it is set to `sequential`, meaning the action's child steps will run sequentially across the OpsChain workers.

_Note: Only `sequential` and `parallel` (as strings or Ruby symbols) are valid values for the `run_as:` parameter._

#### Parallel child step execution

To run child steps in parallel, include the `run_as: :parallel` option in your action definition.

```ruby
action :do_something, steps: ['do_something_after', 'do_something_else_after'], run_as: :parallel do
  # this will run before steps
end

action :do_something_after do
  # runs after do_something
end

action :do_something_else_after do
  # runs at the same time as do_something_after (providing there is a free worker)
end
```

In the example above actions would run in this order:

1. `do_something`
2. `do_something_after` and `do_something_else_after`

_Notes:_

- _Parallel task execution is limited by the number of available OpsChain workers_
- _Care must be taken when modifying properties from within parallel steps. See the [changing properties in parallel steps](properties.md#changing-properties-in-parallel-steps) section of the [OpsChain properties guide](properties.md#opschain-properties-guide) for more information_

#### Modifying the child execution strategy

When using [dynamic child steps](#dynamic-child-steps), it may be necessary to override the child step execution strategy. This is performed by assigning the new value to `OpsChain.child_execution_strategy`.

_Note: The override value will be used as the execution strategy for all child steps of the action. E.g._

```ruby
action :conditional_strategy, steps: ['do_something_after', 'do_something_else_after'], run_as: :parallel do
  if some_condition
    OpsChain.append_child_steps('do_the_final_thing')
    OpsChain.child_execution_strategy = :sequential
  end
end
```

In the example above, `conditional_strategy` has two possible outcomes:

1. If "some_condition" is true, the `do_the_final_thing` action will be added to the child steps of `do_something`. As this action performs the "final thing", we want it to run after `do_something_after` and `do_something_else_after` have completed. To do this, the child execution strategy for `do_something` is altered to run all of its children sequentially and the actions would run in this order:
    1. `conditional_strategy`
    2. `do_something_after`
    3. `do_something_else_after`
    4. `do_another_thing`
2. If "some_condition" is false, the actions would run in this order:
    1. `conditional_strategy`
    2. `do_something_after` and `do_something_else_after`

#### Accessing child execution strategy

The strategy that will be used to run the current action's child steps is available via `OpsChain.child_execution_strategy`.

```ruby
action check_strategy: ['conditional_strategy'], steps: ['child1', 'child2'], run_as: :parallel do
  if OpsChain.child_execution_strategy == :sequential
    OpsChain.logger.info "conditional_strategy changed the strategy to sequential"
  end
end
```

In the example above, `check_strategy` executes `conditional_strategy` (from the [modifying the child execution strategy](#modifying-the-child-execution-strategy) example) as a prerequisite. Using `OpsChain.child_execution_strategy`, `check_strategy` can detect if `conditional_strategy` altered the child execution strategy from `parallel` to `sequential`.

### Notes and limitations

#### Multiple action definitions

If the same action is defined multiple times in your `actions.rb`, each subsequent definition extends the existing action:

```ruby
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

#### Marking a change as errored

In order for a step (and subsequently the change) status to be set to `error`, the `action` must raise an `Exception`.

## OpsChain logger

OpsChain provides a logger for use in actions.

The OpsChain logger is a standard Ruby Logger object. By default the logger is configured to log all INFO severity (and higher) messages to STDOUT. You can use the OpsChain logger from anywhere in your `actions.rb` or project code:

```ruby
OpsChain.logger.info 'Informational message'
OpsChain.logger.warn 'Warning message'
OpsChain.logger.error 'Error message'
OpsChain.logger.fatal 'Fatal message'
```

If required, the logger can be set to also display DEBUG level messages as follows:

```ruby
OpsChain.logger.level = ::Logger::DEBUG
OpsChain.logger.debug 'Debug message'
```

## Defining resource types & resources

_If this is the first time you've looked at OpsChain resource types and resources, our [developer getting started guide](/docs/getting_started/developer.md) could be a good place to start._

Resource types can be defined using the `resource_type` keyword:

```ruby
resource_type :city do
  property :name
  property :weather

  action :report_weather do
    puts "The weather in #{name} looks #{weather}"
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

_Note: The resource type name (`city`) and resource name (`melbourne`) should conform to ruby variable naming standards. This means the name can include alphanumeric characters and the underscore character however it cannot start with a number or a capital letter. This ensures it can be easily referenced from other ruby code or the command line._

### Controller

Defining inline actions as in the example above limits your ability to adequately test the action code. Moving the code into a controller class allows the code to more readily be tested and reduces the need to change your resource type definition to change its action logic.

Re-writing the example above to make use of a controller simplifies the resource type definition:

```ruby
class CityController
  def initialize(options)
    @name = options[:name]
    @weather = options[:weather]
  end

  def report_weather
    puts "The weather in #{name} looks #{weather}"
  end

  private

  attr_reader :name, :weather
end

resource_type :city do
  controller CityController, action_methods: [:report_weather]

  property :name
  property :weather
end
```

_Note: the `action_methods` keyword will expose each controller method supplied to it as an action on the resource._

Resources created from this `city` resource type would have the same actions (and same action output) as those created from the earlier type definition.

Notes:

- The class constructor must accept a single [Ruby hash](https://ruby-doc.org/core-2.7.0/Hash.html) parameter, which will include each of the resource properties defined on the resource. This hash is the resource's `properties` at the time the controller is constructed.
- The action methods must not require parameters.

#### Controller actions and properties

Controllers can define the `resource_type_actions` and/or `resource_type_properties` class methods to expose their default actions and properties to OpsChain. Using these methods, the example above could be re-written as:

```ruby
class CityController
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

  private

  attr_reader :name, :weather
end

resource_type :city do
  controller CityController
end
```

Once again, resources created from this `city` resource type would have the same actions (and same action output) as those created from the earlier type definitions.

_Note: If you supply the `action_methods:` parameter when defining the resource type's controller, the controller's `resource_type_actions` will be ignored and only those methods passed to `action_methods:` will be exposed._

##### Controller action method validation

OpsChain validates that the controller defines all the methods that the resource type references (either via `action_methods` or `resource_type_actions`), and if the method does not exist it will report an error, e.g. `CityController does not define the action method magic`.

If using `method_missing` with an OpsChain controller class then the corresponding `respond_to_missing?` method should be implemented.

If the class defines methods dynamically (or shouldn't be validated for another reason) the `self.validate_action_methods` method can be defined on the controller class to modify this behaviour:

```ruby
class CityController
  def self.validate_action_methods
    false
  end

  def initialize(options)
    define_singleton_method(:magic) do
      puts "Who doesn't like magic?"
    end
  end
end

resource_type :city do
  controller CityController, action_methods: [:magic]
end
```

### Defining resource type actions

Any combination of controller actions and locally defined actions can be used within a resource or resource type.

```ruby
resource_type :city do
  controller CityController

  action :send_postcard do
    puts "Sending postcard from #{name}"
  end
end
```

Using this `city` resource type, resources will include the `report_weather` and `send_postcard` actions.

_Note: If you define a resource type action with the same name as a controller action_method, OpsChain will run the controller action, then the resource_type action._

#### Accessing the controller

If a controller class was configured with the `controller` keyword on the resource type, the actions on the resource or resource type can reference the supporting controller instance to invoke methods.

```ruby
resource_type :city do
  controller CityController

  action :send_postcard do |action|
    action.controller.buy_stamp # this method doesn't actually exist in our example, it is just for illustration
    puts "Sending postcard from #{name}"
  end
end
```

The `send_postcard` action defined on the `city` resource type will invoke the controller's `buy_stamp` method. This method needs to be public, and could optionally be exposed as an action by the controller - but it does not need to be.

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

### Referencing resources

#### Assigning resources to properties

Previously defined resources (in the same `actions.rb` or files required previously) can be referenced by name when setting properties in other resources.

```ruby
namespace :australia do
  city :sydney do
    name 'Sydney'
  end

  namespace :victoria do
    city :melbourne do
      name 'Melbourne'

      # OpsChain will search for the 'sydney' resource in the current namespace, then in
      # each parent namespace until the resource is found.
      rival sydney
    end
  end
end
```

If the property value being assigned (in this case the `sydney` resource) is another resource (technically, if it responds to the `controller` method), the property will be assigned the result of the `controller` method. _**Note: if the controller method returns `nil`, the property will be nil.**_

#### Accessing resource properties

The resource properties from previously defined resources can be referenced when setting properties in subsequent resources by using the `properties` keyword:

```ruby
namespace :australia do
  city :sydney do
    name 'Sydney'
  end

  namespace :victoria do
    city :melbourne do
      name 'Melbourne'
      rival "#{name}'s biggest rival is #{sydney.properties.name}."
    end
  end
end
```

#### The `ref` method

As shown in the previous examples, referencing a resource by name is often sufficient to resolve it. However, when the required resource is defined in an alternate namespace, or where resources with the same name exist, the `ref` method can be used to more explicitly specify the required resource:

```ruby

namespace :australia do
  city :capital do
    name 'Canberra'
  end

  namespace :victoria do
    city :capital do
      name 'Melbourne'
    end
  end

  namespace :new_south_wales do
    city :capital do
      name 'Sydney'
    end

    namespace :hunter_valley do
      city :newcastle do
        state_capital capital
        country_capital ref('^australia:capital')
        victorian_capital ref('victoria:capital') # or ref('^australia:victoria:capital')
      end
    end
  end
end
```

The properties associated with `newcastle` highlight the various ways to access other resources in the `actions.rb`.

-`state_capital` uses the default "by name" feature of the DSL causing the following search sequence:

  1. `australia:new_south_wales:hunter_valley:capital`
  2. `australia:new_south_wales:capital`

-`country_capital` prefixes the resource path with the `^` symbol to instruct `ref` to start its search in the root namespace:

  1. `australia:capital`

-`victorian_capital` includes a namespace in the resource path, causing the following search sequence:

  1. `australia:new_south_wales:hunter_valley:victoria:capital`
  2. `australia:new_south_wales:victoria:capital`
  3. `australia:victoria:capital`

  It also includes an alternative path, using the `^` prefix to request the Victorian capital directly.

#### Using resources in actions

Before executing a resource action, OpsChain parses the entire `actions.rb` file. For this reason, resource actions can refer to any resource in the `actions.rb` or the files it requires. In the example below, the `state_capital` action refers to the `melbourne` resource, even though its definition appears after it in the file.

```ruby
namespace :victoria do
  city :bacchus_marsh do
    name 'Bacchus Marsh'

    action :state_capital do
      puts "The capital of Victoria is #{melbourne.properties.name}."
      melbourne.controller.report_weather
    end
  end

  city :melbourne do
    name 'Melbourne'
  end
end
```

The `state_capital` action uses:

- the `properties` keyword to incorporate the value of the `melbourne` resource's `name` property in the message
- the `controller` keyword to call the `report_weather` method on `melbourne`'s controller

_Note: Within an `action` block, OpsChain does not allow calling other resource's actions directly (e.g. `melbourne.send_postcard` can not be used from the `state_capital` action above). If the `send_postcard` action is required from other resources, it should be moved to a method in the resource type's controller, making it accessible via the `controller` keyword._

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
  properties({ name: 'Melbourne', weather: 'cold' })
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

The example above would result in the creation of a controller with these properties:

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

These actions can have prerequisites and initiate subsequent steps like normal actions:

```ruby
city :melbourne do
  name 'Melbourne'

  action :get_coffee do
    puts 'getting coffee'
  end

  action :see_music do
    puts 'seeing music'
  end

  action :visit, steps: ['get_coffee', 'see_music']
end
```

Any actions defined within a resource will run __after__ controller and resource type actions with the same name. The following code can be used to demonstrate:

```ruby
class CityController
  ... # omitted for simplicity
  def report_weather
    puts "The controller weather in #{name} looks #{weather}"
  end
end

resource_type :city do
  controller CityController, action_methods: [:report_weather]

  action :report_weather do
    puts "The resource_type weather in #{name} looks #{weather}"
  end
end

city :melbourne do
  name 'Melbourne'
  weather 'perfect'

  action :report_weather do
    puts "The resource weather in #{name} looks #{weather}"
  end
end
```

This example will output the controller weather, then the resource_type weather, then the resource weather. The `name` and `weather` properties will be the same in all three messages.

The following code creates a `database` resource type with three actions: `copy_installer`, `install_and_startup` and `startup`. (`database_controller` is a hypothetical file containing a `DatabaseController` class.)

```ruby
require 'database_controller'

resource_type :database do
  controller DatabaseController, action_methods: [:copy_installer, :startup]

  property :host
  property :source_path

  action install_and_startup: [:copy_installer], steps: [:startup] |action|
    action.controller.install
  end
end
```

The `install_and_startup` action will:

1. in the current step runner, execute the `copy_installer` pre-requisite action (to execute the `copy_installer` controller method)
2. in the current step runner, execute the `install` controller method (manually called from within the action body)
3. request the `startup` action be run as a child step (to execute the `startup` controller method) - this child step will be started after the contents of this step complete and will be run in a new step runner

## Defining composite resources & resource types

You can define a composite resource that manages child resources.

- `children` specifies the keys and values to be iterated over, it is supplied when creating a resource
- `each_child` defines a namespace for each child and defines a copy of any configured actions and resources in that namespace
- `child_actions` can be used to reference the actions of each child. This is useful for actions defined at the parent composite resource (or resource type) level that may want to reference these child actions as steps

These can be used in a resource definition to create child resources specific to that resource. More commonly, they can be used in a resource type definition to create child resources for each resource of this type.

```ruby
suburb_properties = {
  richmond: {
    football_team: 'tigers'
  },
  collingwood: {
    football_team: 'magpies'
  }
}

resource_type :team

resource_type :city do
  property :country

  each_child do |suburb, properties|
    team :local_team do
      properties properties
      action :barrack do
        puts "Go #{suburb} #{properties[:football_team]} - the best team in #{country}!"
      end
    end
  end

  action :barrack_all, steps: child_actions('local_team:barrack')
end

city :melbourne do
  country 'Australia'
  children suburb_properties
end
```

This would define the following actions:

- `melbourne:richmond:local_team:barrack`
- `melbourne:collingwood:local_team:barrack`
- `melbourne:barrack_all` - this will call the `local_team:barrack` action on the `city` composite's children (`richmond` and `collingwood`).

_Notes:_

- _Each team's `barrack` action makes use of the `country` property defined on the parent `city` composite resource type_
- _`actions` can't be created directly inside the `each_child` block, and instead must be on a resource_

## What to do next

Learn about the OpsChain [step runner](step_runner.md).

Learn about the [Docker development environment](../../docker_development_environment.md).

Try [developing your own resources](../../getting_started/developer.md#developing-resources).

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
