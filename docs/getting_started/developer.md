# Getting started - developer edition

The `actions.rb` in the project Git repository is the core of an OpsChain change. After following this guide you should understand:

- how to add actions to the `actions.rb` file for use in a change
- how to add resource types and resources to the `actions.rb` file for use in a change
- how to create a simple controller to support a resource type

## Prerequisites

If you have not already done so, we suggest completing the main [getting started guide](README.md) before this guide.

This guide assumes that:

- you have have access to a running OpsChain API server, either locally or network accessible. See the [getting started installation guide](../operations/installation.md) for more details
- you have performed the [Docker Hub login step](../operations/installation.md#configure-docker-hub-access-optional) from the getting started installation guide
- you have installed:
  - the [OpsChain CLI](../reference/cli.md#installation)
  - [Docker](https://docs.docker.com/engine/install/)
  - [Docker Compose](https://docs.docker.com/compose/install/)

### Create a Git repository

OpsChain projects can use remote Git repositories to centrally manage configuration.

Create a new Git repository for this guide:

```bash
mkdir opschain-git-repo
cd opschain-git-repo
git init
```

This guide uses an existing repository that already contains some sample content. [Fork the sample repo on GitHub](https://docs.github.com/en/get-started/quickstart/fork-a-repo) and use your own fork to allow you to push your changes and use them from your OpsChain project.

```bash
git remote add origin https://{github username}:{github personal access token}@github.com/{github username}/opschain-getting-started.git
git fetch
git checkout developer-guide
```

#### Repository setup

All OpsChain project Git repositories must contain a `Gemfile` and an `actions.rb`.

```bash
$ tree
├── Gemfile
└── actions.rb
```

By using the existing sample repository these files have already been created - but with normal repositories they will need to be created manually.

## Running OpsChain actions

OpsChain changes run actions from a project's Git repository.

OpsChain actions can be developed interactively in the OpsChain development environment, accessed via the `opschain dev` CLI subcommand.

_Note: Throughout the documentation, the following prefixes for bash commands will be used to denote where the command should be run._

- _`[host] $` execute the command on your local host_
- _`[dev] $` execute the command inside the OpsChain development environment_

### Developing actions locally

Start the OpsChain development environment:

```bash
# From your project repository folder
[host] $ opschain dev
```

The OpsChain development environment opens a Bash prompt within an OpsChain runner container. You can now use the `opschain-action` utility to list the actions available within the current project Git repository:

```bash
[dev] $ opschain-action -AT # this will list all actions - use `opschain-action -T` to show only actions with a description
```

The sample branch we checked out earlier has an `actions.rb` file in the repository that contains a single action, `hello_world`.

You can run this action in the development environment by using the `opschain-action` command as follows:

```bash
[dev] $ opschain-action hello_world
Hello world
```

_Note: Once an action is ready, the `opschain change create` command should be used to execute it via the OpsChain server to gain the collaboration and auditing benefits that OpsChain provides. This also allows the change to run with secure network access that can be granted to the OpsChain server, without giving that network access directly to developers._

### Adding a new action

Open the `actions.rb` file with your favourite editor so that you can add a new action to the Git repository.

Add the following to the bottom of the file (after the `hello_world` action):

```ruby
desc 'Say goodbye world' # if this line were omitted then this action would not be shown in the tasks displayed by `opschain-action -T`
action :goodbye_world do
  puts 'Goodbye world' # you could write any Ruby in here, but OpsChain provides a friendlier API in addition to this
end
```

You can now manually run the new `goodbye_world` task in addition to the existing `hello_world` task:

```bash
[dev] $ opschain-action hello_world goodbye_world
Hello world
Goodbye world
```

Add the following to the `actions.rb` file to configure the project to run both of these actions as the default action (i.e. when you don't specify which action to run):

```ruby
action default: [:hello_world, :goodbye_world]
```

You can now run the default action:

```bash
[dev] $ opschain-action
Hello world
Goodbye world
```

#### Leveraging OpsChain steps

Splitting OpsChain actions into steps allows OpsChain to:

- isolate the step execution - to avoid concurrency conflicts and improve security
- report on the progress of a change

To help your changes complete faster, steps can also run in parallel - we'll cover this later.

Steps are run in isolated runner containers when run as part of an OpsChain change.

Edit the `actions.rb` file to make the `default` action run it's dependent actions as steps:

```ruby
action :default, steps: [:hello_world, :goodbye_world]
```

Child steps are always run automatically when running a change, however to automatically run these child steps when running them in the OpsChain development environment the `OPSCHAIN_ACTION_RUN_CHILDREN` environment variable must be set to `true`:

```bash
[dev] $ opschain-action
2021-01-01 12:05:00.000+1000 WARNING: Child steps (hello_world, goodbye_world) will not be executed - set OPSCHAIN_ACTION_RUN_CHILDREN to run locally.
[dev] $ export OPSCHAIN_ACTION_RUN_CHILDREN=true
[dev] $ opschain-action
Hello world
Goodbye world
```

_Tip: Add `export OPSCHAIN_ACTION_RUN_CHILDREN=true` to your host's shell configuration (e.g. `~/.zshrc`) to avoid needing to set it each time you start the development environment._

#### OpsChain lint pre-commit hook

OpsChain provides a linting command for detecting issues in project Git repositories.

This command is automatically setup as a pre-commit hook for project Git repositories created by OpsChain.

If you would like to commit code that fails linting (e.g. incomplete code) the Git `--no-verify` argument can be used when committing, e.g. `git commit --no-verify`.

See the [OpsChain lint](../docker_development_environment.md#using-opschain-dev-lint) documentation to learn more.

#### Commit your action

Commit the changes to the `actions.rb` file to allow them to be used via the OpsChain server:

```bash
[host] $ git add actions.rb
[host] $ git commit -m 'Add a goodbye action and run hello_world and goodbye_world by default.'
```

### Running the action as a change (optional)

Now that you've developed and tested your actions, use the OpsChain server to run them as part of a change. This facilitates collaboration and record keeping, and can also be done to improve security by only executing changes in a secure environment.

This step assumes you have completed the [running sample changes](README.md#setup-opschain-to-run-sample-changes) steps from the getting started guide - alternatively you could create a new [project](README.md#create-an-opschain-project) and [environment](README.md#create-opschain-environments) to run the change in.

#### Push your commit to the remote

Push your new Git commit to the Git repository on GitHub for use by your project Git repository:

```bash
[host] $ git push origin HEAD:hello-goodbye
```

#### Add the project Git remote

Associate your Git repository with the `web` project created during the getting started guide.

```bash
# Note: to avoid potentially storing the repository credentials in the shell history the `-U` (user) and `-P` (password) arguments can be omitted and filled in when prompted
# Option 1: Using password authentication:
$ opschain project add-git-remote -p <project code> -n origin -U '{username}' -P '{password / personal access token}' -u 'https://github.com/{username}/opschain-getting-started.git'
# Option 2: Using SSH authentication:
$ opschain project add-git-remote -p <project code> -n origin -s ./path/to/private/key -u 'git@github.com:{username}/opschain-getting-started.git'
```

#### Run the change

Use the OpsChain CLI to run the change using the OpsChain server. This will run the new steps in isolated containers and will report on the status of each step as it progresses.

```bash
opschain change create -p web -e test -G origin -g hello-goodbye -a '' -y # -a '' is a synonym for -a 'default'
```

Use the `opschain change show-logs` command in another terminal to see the latest log output whilst the change is still executing, or wait until the change completes:

```bash
opschain change show-logs -c xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx # the change ID from the change create output
```

## Developing resources

OpsChain resources and resource types are features of the `actions.rb` file that make your configuration easier to follow and more reusable.

Using resources is very simple, here is an example `temp_file` resource using a non-existent `file` _resource type_ to demonstrate:

```ruby
# this won't work, yet
file :temp_file do
  path '/tmp/testing'
  content 'Hello :-)'
end
```

This `temp_file` resource configures two properties - `path` and `content`. These would need to be supported by the `file` resource type.

Resources can define actions, for example you could define a `create` action as part of this resource:

```ruby
# this won't work, yet
file :temp_file do
  path '/tmp/testing'
  content 'Hello :-)'

  action :create do
    OpsChain.logger.info 'Lets create a file.'
  end
end
```

With a working resource type (which we haven't created yet), you could run this action using `opschain-action temp_file:create` - note how this uses the resource name and the action name.

Resources are instances of resource types. The resource type is the backing definition of the resource.

A basic `file` resource type for the `temp_file` resource above could be:

```ruby
resource_type :file do
  property :path
  property :content
end
```

If we assume all file resources can be created the same way, the `create` action can be moved from the `temp_file` resource to the `file` resource type - this allows it to be reused. Replace the contents of the sample `actions.rb` with the following to demonstrate this:

```ruby
Bundler.require

resource_type :file do
  property :path
  property :content

  action :create do
    OpsChain.logger.info 'Lets create a file.'
  end
end

file :temp_file do
  path '/tmp/testing'
  content 'Hello :-)'
end
```

Now run the `temp_file:create` command:

```bash
[dev] $ opschain-action temp_file:create
2021-01-01 12:05:00.000+1000 Lets create a file.
```

As you can see, this has run the Ruby code in the `create` action. Inside the resource type, modify the action definition to create the file:

```ruby
action :create do
  OpsChain.logger.info "Lets create a file: #{path}"
  File.write(path, content)
end
```

Run the `temp_file:create` command again:

```bash
[dev] $ opschain-action temp_file:create
2021-01-01 12:05:00.000+1000 Lets create a file: /tmp/testing
[dev] $ cat /tmp/testing
Hello :-)
```

Creating files in the short-lived OpsChain development container isn't the most useful - lets make the host where the resource type will create the file configurable. OpsChain provides some tools to make this more convenient.

Add the `opschain-resource-types` Gem to your Gemfile (see the [included resource types guide](/docs/reference/included_resource_types.md) to learn more about this Gem):

```ruby
# The following Gems are pre-installed on the OpsChain runner image
gem 'opschain-core', require: 'opschain'
# the require below automatically requires `opschain-infrastructure` (rather than doing it manually in the actions.rb)
# `require:` uses an array because `opschain-resource-types` includes many paths that can be required, and in the future more could be required here
gem 'opschain-resource-types', require: ['opschain-infrastructure']
```

To load the new Gem:

```bash
[dev] $ rm -f Gemfile.lock; bundle install
```

Update your `actions.rb` with the following:

```ruby
Bundler.require

resource_type :file do
  property :path
  property :content
  property :host

  host MintPress::Infrastructure::Localhost.new

  action :create do
    OpsChain.logger.info "Lets create a file: #{path}"
    host.transport.File.write(path, content)
  end
end

file :temp_file do
  path '/tmp/testing'
  content 'Hello :-)'
end
```

Run the temp_file action again:

```bash
[dev] $ rm -f /tmp/testing
[dev] $ export MINTPRESS_LOG_LEVEL=error # hide the detailed logging - it's not necessary for this guide
[dev] $ opschain-action temp_file:create
2021-01-01 12:05:00.000+1000 Lets create a file: /tmp/testing
[dev] $ cat /tmp/testing
Hello :-)
```

So far, nothing has changed - the file has still been created locally - but there is now a `host` property on the resource type (which is defaulted to localhost).

Add a local `infrastructure_host` resource to leverage that property:

```ruby
infrastructure_host :test_host do
  protocol 'local'
end

file :temp_file do
  host test_host
  path '/tmp/testing'
  content 'Hello :-)'
end
```

Again, using the `temp_file:create` action will do this locally.

To show this code working with a remote host, the repository includes a `docker-compose.yml` file to create an `opschain-getting-started` Docker network, with a `target` host that we can treat like a remote host:

```bash
[host] $ docker-compose up -d
```

Once `docker-compose` completes, we need to add the OpsChain development environment container to the `opschain-getting-started` network so it can communicate with it.

```bash
[host] $ docker network connect opschain-getting-started "$(docker ps --filter 'label=opschain-dev' -q)"
```

Return to the terminal running the OpsChain development environment to perform the following steps.

Update the `test_host` resource to use the sample container:

```ruby
infrastructure_host :test_host do
  hostname 'target'
  connect_user 'opschain'
  password 'password'
end
```

Run the action again:

```bash
[dev] $ rm -f /tmp/testing
[dev] $ opschain-action temp_file:create
2021-01-01 12:05:00.000+1000 Lets create a file: /tmp/testing
[dev] $ cat /tmp/testing
cat: /tmp/testing: No such file or directory
```

Now the file does not exist locally as it has been created on the remote host.

In a new terminal verify that the new file exists:

```bash
$ docker exec target cat /tmp/testing
Hello :-)
```

This example leverages the MintPress `InfrastructureHost` and `Transport` classes which can transparently execute code on remote or local hosts. View the [MintPress documentation](https://docs.limepoint.com/mintpress/examples/interacting-with-transport/) for these classes to learn more about the powerful functions they provide - if you need credentials to access this documentation contact [OpsChain support](mailto:opschain-support@limepoint.com).

To complete the new `file` resource example, update the contents of your `actions.rb` as follows:

```ruby
Bundler.require

infrastructure_host :test_host do
  hostname 'target'
  connect_user 'opschain'
  # tip: use OpsChain database properties for credentials like passwords as they are stored securely
  password 'password'
end

resource_type :file do
  property :path
  property :content
  property :host

  host test_host # NOTE we've made test_host the default, but we can override it in a resource if we desire

  action :create do
    OpsChain.logger.info "Lets create a file: #{path}"
    host.transport.File.write(path, content)
  end
end

file :temp_file do
  path '/tmp/testing'
  content 'Hello :-)'
end

file :another_temp_file do
  path '/tmp/testing2'
  content 'Goodbye :-)'
end

desc 'Create sample files'
action :default, steps: ['temp_file:create', 'another_temp_file:create']
```

Running `[dev] $ OPSCHAIN_ACTION_RUN_CHILDREN=true opschain-action` now will create two files on the target host.

### Moving the complexity to a reusable controller

In addition to creating files, the `file` resource type could also delete files.

As we are adding this extra complexity to the resource type, moving the Ruby code to a controller will simplify the resource and resource type. This simplifies the `actions.rb` and keeps it focussed on configuration rather than implementation.

Moving the code to a Ruby controller class also allows developers to add unit tests to ensure the code is tested and reliable.

Create a new file, `lib/controllers/file_controller.rb`, with the following contents:

```ruby
class FileController
  def initialize(opts)
    @host, @path, @content = opts.values_at(:host, :path, :content)
  end

  def create
    OpsChain.logger.info "Lets create a file: #{@path}"
    @host.transport.File.write(@path, @content)
  end
end
```

Modify the top of the `actions.rb` as follows:

```ruby
Bundler.require
require_relative 'lib/controllers/file_controller'
```

Then, simplify the resource type:

```ruby
resource_type :file do
  controller FileController, action_methods: [:create]
  property :path
  property :content
  property :host
  host test_host # NOTE we've made test_host the default, but we can override it in a resource if we desire
end
```

Running `[dev] $ opschain-action` will now use the new controller to create two files.

Notice that the `action_methods` argument has specified that this controller's `create` method should be exposed as an action on the `file` resource type.

Update the contents of the controller to add a new `delete` method. Rather than updating the `action_methods` argument in the resource type, the class can implement a `self.resource_type_actions` method:

```ruby
class FileController
  def self.resource_type_actions
    [:create, :delete]
  end

  def initialize(opts)
    @host, @path, @content = opts.values_at(:host, :path, :content)
  end

  def create
    OpsChain.logger.info "Lets create a file: #{@path}"
    @host.transport.File.write(@path, @content)
  end

  def delete
    OpsChain.logger.info "Deleting file: #{@path}"
    @host.transport.File.delete(@path)
  end
end
```

Update the resource type to use the `self.resource_type_actions` method by removing the `action_methods` configuration (`action_methods` overrides the controller `resource_type_actions`):

```ruby
resource_type :file do
  controller FileController
  property :path
  property :content
  property :host
  host test_host # NOTE we've made test_host the default, but we can override it in a resource if we desire
end
```

Listing the actions available using the `opschain-action` command now includes the new delete command:

```bash
[dev] $ opschain-action -AT temp_file: # adding the `temp_file:` here filters the output to only show actions that match this pattern
opschain-action another_temp_file:create  #
opschain-action another_temp_file:delete  #
opschain-action temp_file:create          #
opschain-action temp_file:delete          #
```

Try running the delete command to remove one of the files:

```bash
[dev] $ opschain-action temp_file:delete
2021-01-01 12:05:00.000+1000 Deleting file: /tmp/testing
```

To further simplify the resource type, implement a `self.resource_type_properties` method in the controller class:

```ruby
class FileController
  # add these at the top to make it easier for others to quickly see the properties and actions that are supported
  def self.resource_type_properties
    [:host, :path, :content]
  end

  ...
end
```

Then simplify the resource type in the `actions.rb`:

```ruby
resource_type :file do
  # note that the order is important, if we swapped the following lines this would fail with `NoMethodError: undefined method `host' for #<OpsChain::Dsl::ResourceConfiguration:0x0000000003b15208>`
  controller FileController
  host test_host
end
```

To facilitate changes that remove the temporary files, add a `clean` action to the `actions.rb` file to remove these two files, working in parallel to improve the performance:

```ruby
desc 'Remove sample files'
action :clean, steps: ['temp_file:delete', 'another_temp_file:delete'], run_as: :parallel
```

By adding descriptions to the core actions in the `actions.rb` they will be listed when running `opschain-action -T` - which only lists actions with a description:

```bash
[dev] $ opschain-action -T
opschain-action clean    # Remove sample files
opschain-action default  # Create sample files
```

Doing this is considered a best practice - especially in a team environment where it tells other team members about the key actions in a project Git repository.

### Making the target host configurable

By defining the target host as an [OpsChain property](../reference/concepts/properties.md) we allow the host to be overridden independently of the Git repository.

```ruby
infrastructure_host :test_host do
  properties OpsChain.properties.target_host
end
```

Lets create an in-repository set of default properties (these will be used if the project or environment doesn't provide overrides) - this is not mandatory in all project repositories, but is for this example:

```bash
[dev] $ mkdir -p .opschain
[dev] $ cat <<EOH > .opschain/properties.json
{
  "target_host": {
    "protocol": "local"
  }
}
EOH
```

Here we've used [JSON](https://www.json.org/json-en.html), but OpsChain also supports [TOML](https://github.com/toml-lang/toml) and [YAML](https://yaml.org/) as `properties.toml` and `properties.yaml` respectively.

#### Setting a remote target (optional)

To use the changes against a remote host, the project or environment properties would need to be updated to specify a remote host to target - by default it would just act locally due to the default `properties.json` in the repository.

An example properties file could be:

```json
{
  "target_host": {
    "hostname": "my-server.example.com",
    "connect_user": "opschain",
    "password": "password"
  }
}
```

_Note: The values would need to be updated to match a server that the OpsChain API could access._

#### Commit your updates

Commit the changes to the `actions.rb` and `lib/controllers/file_controller.rb` files to allow them to be used via the OpsChain server:

```bash
[dev] $ git add Gemfile actions.rb lib/controllers/file_controller.rb .opschain/properties.json
[dev] $ git commit -m 'Example creating and removing files.'
```

Once committed, the code can be pushed to the Git remote and can then be used as part of a change by following the same process as [earlier](#running-the-action-as-a-change-optional).

#### A completed example

The sample repository includes the `developer-guide-complete` branch which is a completed example of this tutorial.

It includes the `actions.rb` with resources and actions, the `file` resource type, and the `FileController` with tests (in the `spec` directory).

## Remove `target` container and `opschain-getting-started` network

_Note: Before running the command below, ensure you have exited the OpsChain development environment._

```bash
[host] $ docker-compose down
```

## What to do next

### Learn more about OpsChain actions

Read our more comprehensive [actions reference guide](../reference/concepts/actions.md#actions-reference-guide) to learn more about creating actions, resources, resource types and controllers.

### Create OpsChain actions that need manual intervention

Read more about [OpsChain wait steps](../reference/concepts/actions.md#wait-steps) to learn how to create changes that can pause and wait for human intervention before continuing.

### Learn more about the OpsChain step runner

Read our more comprehensive [step runner guide](../reference/concepts/step_runner.md) to learn more about how OpsChain steps are executed - and how to install custom commands and dependencies.

### Learn more about OpsChain properties

Follow the [loading properties](../reference/concepts/properties.md#loading-properties) guide to try editing some [project](../reference/concepts/concepts.md#project) or [environment](../reference/concepts/concepts.md#environment) properties.

### Try more advanced examples

The [OpsChain examples](../examples/README.md) include a variety of tutorials and Git repository samples for you to explore.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
