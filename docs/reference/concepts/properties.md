# OpsChain properties guide

The OpsChain properties framework provides a location to store:

- key value pairs
- environment variables and values (that will be available in the Unix environment running a change action)
- files (that will be written before running a change action)

OpsChain properties can be stored in your project's Git repository and also at the project or environment level in the OpsChain database. For those properties stored in the database OpsChain maintains a complete version history of each change made to the OpsChain properties JSON, enabling you to view and compare the properties used for any change. Similarly, Git version history can be used to identify changes made to the repository properties.

After following this guide you should understand:

- how to incorporate OpsChain properties into your Git repository
- how to import OpsChain properties into the database using the CLI
- how to view project and environment OpsChain properties from the CLI and API server
- the various types of values that can be stored in OpsChain properties
- the difference between OpsChain properties and OpsChain context values

## OpsChain properties

Within each action, OpsChain properties are available via `OpsChain.properties` (which will behave like a [Hashie Mash](https://github.com/hashie/hashie#mash)[^1])). The values available are the result of a deep merge of the [change's](concepts.md#change) [project's Git repository](../project_git_repositories.md) properties with the [project](concepts.md#project) and [environment](concepts.md#environment) level properties. If a property exists at multiple levels, project values will override repository values and environment values will override project and repository values.

Properties can be accessed using dot or square bracket notation with string or symbol keys. These examples are equivalent:

```ruby
require 'opschain'

OpsChain.properties.server.setting
OpsChain.properties[:server][:setting]
OpsChain.properties['server']['setting']
```

_Notes:_

1. _You will not be able to use dot notation to access a property with the same name as a method on the properties object (for example `keys`). In this case you must use square bracket notation instead._
2. _Any arrays in the properties will be overwritten during a deep merge (use JSON objects with keys instead to ensure they are merged)_
3. _The `OpsChain.properties` structure is read only. Please see [modifiable properties](#modifiable-properties) below for information on making changes to the environment or project properties._

### Comparison with OpsChain context

In addition to the user defined and maintained OpsChain properties available in an OpsChain change, OpsChain also provides OpsChain context values.

The OpsChain context is automatically populated by OpsChain with information about the context in which a change is run, for example the environment name or the action being executed by the change.

Rather than manually putting change related values - e.g. the environment code, project code, action name, etc. - into your properties, consider whether you could use the OpsChain context instead.

See the [OpsChain context guide](context.md) if you would like to learn more about the OpsChain context framework.

## Storage options

### Git repository

OpsChain will look for the following files in your project's Git repository:

1. `.opschain/properties.json`
2. `.opschain/properties.toml`
3. `.opschain/properties.yaml`
4. `.opschain/environments/<environment code>.json`
5. `.opschain/environments/<environment code>.toml`
6. `.opschain/environments/<environment code>.yaml`

If more than one of these files exist in the repository, they will be merged together in the order listed above. When two files define the same property/value, the latter file's value will override the former. E.g. if `.opschain/properties.toml` and `.opschain/environments/<environment code>.json` both contain the same property, the value from `.opschain/environments/<environment code>.json` will be used.

Within each action, the result of merging these files will be available via `OpsChain.repository.properties`.

#### Notes

1. The repository properties are read only within each action (as OpsChain cannot modify the underlying Git repository to store any changes).
2. Loading repository properties in the [OpsChain development environment](../../docker_development_environment.md) (`opschain dev`):
   - running `opschain-action -AT` will raise explanatory exceptions if the schema or structure of these file(s) is invalid.
   - the `<environment code>.[json|toml|yaml]` files will be loaded by `opschain-action` if the `step_context.json` file includes the relevant context environment code. e.g.

    ```yaml
    {
      "context": {
        ...
        "environment": {
          "code": "<environment code>",
          ...
        }
      },
      ...
    }
    ```

### Database

Properties stored in the database are encrypted prior to being written to disk such that they are encrypted-at-rest. Within each action, project properties are available via `OpsChain.project.properties`. Similarly environment properties are available via `OpsChain.environment.properties`.

#### Loading properties

The OpsChain CLI allows you to set properties at the project or environment level. First create a JSON file to import. E.g.

```bash
$ cat << EOF > my_opschain_properties.json
{
  "basic_prop": "some value",
  "parent_prop": {
    "nested_prop": "some other value"
  }
}
EOF
```

Now import the properties against the project:

```bash
opschain project set-properties --project-code <project code> --file-path my_opschain_properties.json --confirm
```

or environment:

```bash
opschain environment set-properties --project-code <project code> --environment-code <environment_code> --file-path my_opschain_properties.json --confirm
```

_Note: If the environment or project properties are in use by an active change, the API server will reject the set-properties request. This ensures OpsChain can guarantee the properties state throughout the life of the change._

#### Viewing properties

The OpsChain CLI allows you to view the stored properties:

```bash
opschain project show-properties --project-code <project code>
opschain environment show-properties --project-code <project code> --environment-code <environment_code>
```

The CLI does not currently support viewing prior versions of the properties. To do this you will need to interact directly with the OpsChain API server. The project API location:

```text
http://<host>:3000/projects/<project code>
```

The environment API location (the link below will respond with all environments for the project specified - review the output for the environment of interest):

```text
http://<host>:3000/projects/<project code>/environments
```

The relevant API response will contain a link to the properties associated with that object in `/data/relationships/properties/links/related`. This will return the current properties values, including the current version number (in `/data/attributes/version`). To request a different version of the properties, simply append `/versions/VERSION_NUMBER` to the url. E.g.

```text
http://<host>>:3000/properties/<properties id>/versions/7
```

## Properties content

### Key value pairs

You can use OpsChain key value properties from anywhere in your `actions.rb` to provide environment (or project) specific values to your resource actions. E.g.

```ruby
database :my_database do
  host OpsChain.properties.database.host_name
  source_path OpsChain.properties.database.source_path
end
```

#### Modifiable properties

In addition to the read only values available from `OpsChain.properties`, the project and environment specific properties are available via:

```ruby
OpsChain.project.properties
OpsChain.environment.properties
```

These are exposed to allow you to add, remove and update properties, with any modifications saved on [step](concepts.md#step) completion. The modified project and environment properties are then available to any subsequent [steps](concepts.md#step) or [changes](concepts.md#change).

The object returned by `OpsChain.properties` is the merged set of properties and is regenerated every time the method is called. This means that if the result of `OpsChain.properties` is assigned to a variable - or passed to a resource - it won't reflect updates.

```ruby
puts OpsChain.properties.example # ''
props = OpsChain.properties
OpsChain.project.properties.example = 'hello'
puts OpsChain.properties.example # 'hello'
puts props.example # '' - this value was not updated
```

##### Creating / updating properties within actions

The following code will set the project `server_name` property, creating or updating it as applicable:

```ruby
OpsChain.project.properties.server_name = 'server1.limepoint.com'
```

_Note. As properties behave like a Hashie::Mash, creating multiple levels of property nesting in a single command requires you to supply a hash as the value. E.g._

```ruby
OpsChain.project.properties.parent = { child: { grandchild: 'value' } }
```

Once created, nested properties can be updated as follows:

```ruby
OpsChain.project.properties.parent.child.grandchild = 'new value'
```

##### Deleting properties

To delete the grandchild property described above, use the following command:

```ruby
OpsChain.project.properties.parent.child.delete(:grandchild)
```

_Note. This would leave the parent and child keys in the project properties. To delete the entire tree, use the following command:_

```ruby
OpsChain.project.properties.delete(:parent)
```

##### Example

An example of setting properties can be seen in the [Confluent example](https://github.com/LimePoint/opschain-examples-confluent). The `provision` [action](concepts.md#action) in [`actions.rb`](https://github.com/LimePoint/opschain-examples-confluent/blob/master/actions.rb) modifies the environment properties to change settings for broker1.

#### Changing properties in concurrent steps

Changes that take advantage of the `:parallel` [change execution strategy](actions.md#child-execution-strategy) will cause OpsChain to run multiple steps concurrently. Similarly, starting multiple changes at once will also lead to steps executing concurrently.

When each step starts, the current state of the project and environment properties (in the OpsChain database) is supplied to the step's action(s). This means steps that run concurrently will start with the same set of properties. At the completion of each step, any changes made to the project and/or environment properties by the action, are reflected in a [JSON Patch](http://jsonpatch.com/) applicable to the relevant source properties. The JSON Patch(es) are returned from the step runner to the OpsChain API and applied to the current state of the database properties. It is up to the action developer to ensure any changes made to properties by concurrent steps are compatible with each other.

_Note: OpsChain recommends that you do not modify properties from within concurrent steps. However, if this is a requirement, ensuring the modifications apply to unrelated sections of the OpsChain properties will mitigate the risk. The following sections describe various types of properties changes and the possible errors you may encounter. For simplicity, the examples all show concurrent steps created within a single change using the `:parallel` child step execution strategy. Steps executing from changes that have been submitted concurrently can run into similar limitations._

##### Modifying different properties

Using a JSON Patch to apply changes made by actions to the OpsChain properties ensures concurrent steps can modify independent properties successfully. For example:

```ruby
# Sets up an initial set of values for the OpsChain project properties, then calls the foo and bar child actions in parallel
action :default, steps: [:foo, :bar], run_as: :parallel do
  OpsChain.project.properties = { foo: 'old_foo', bar: 'old_bar' }
end

action :foo do
  OpsChain.project.properties.foo = 'new_foo'
end

action :bar do
  OpsChain.project.properties.bar = 'new_bar'
end
```

At the completion of the child steps, the OpsChain project properties will be:

```ruby
{ foo: 'new_foo', bar: 'new_bar' }
```

##### Race conditions

Modifying the same property in concurrent steps will produce unexpected results. In the example below, at the completion of the child steps, the final value of the `race` property will be the value assigned by the child step that completes last.

```ruby
# Sets up an initial set of values for the OpsChain project properties, then calls the foo and bar child actions in parallel
action :default, steps: [:foo, :bar], run_as: :parallel do
  OpsChain.project.properties = { race: 'initial value' }
end

action :foo do
  OpsChain.project.properties.race = 'possible value 1'
end

action :bar do
  OpsChain.project.properties.race = 'possible value 2'
end
```

##### Conflicting changes

In addition to the [race conditions](#race-conditions) example above, changes to OpsChain properties made by concurrent steps can create JSON Patch conflicts that will result in a change failing. The following scenarios are example of parallel steps that will generate conflicting JSON Patches.

_Scenario 1:_ Deleting a property in one child, while modifying that property's elements in the other.

```ruby
action :default, steps: [:foo, :bar], run_as: :parallel do
  OpsChain.project.properties.parent = { child: 'value' }
end

action :foo do
  OpsChain.project.properties.delete(:parent)
end

action :bar do
  OpsChain.project.properties.parent.child = 'new value'
  sleep(10)
end
```

_Scenario 2:_ Modifying the data type of a property in one child, while generating a patch based on the original data type in the other.

```ruby
action :default, steps: [:foo, :bar], run_as: :parallel do
  OpsChain.project.properties.parent = { child: 'value' }
end

action :foo do
  OpsChain.project.properties.parent = 'I am now a string'
end

action :bar do
  OpsChain.project.properties.parent.child = 'new value'
  sleep(10)
end
```

In both scenarios, the `default` action will fail running child step `bar`. As the child steps start with the properties defined by the `default` action, the logic within each child will complete successfully. However, as `bar` (with its included sleep) will finish last, the JSON Patch it produces will fail when OpsChain attempts to apply it as `foo` has changed the `parent` property to be incompatible with the patch made by `bar`. In both cases, the `child` element no longer exists and cannot be modified.

##### Resolving conflicts

If a step's JSON Patches fail to apply, the change will error at the failing step and the logs will provide the following information for each failed patch:

```json
ERROR: Updates made to the project properties in step "[c5556d54-d98f-415e-9198-4134848fb93f] bar" could not be applied.

Original project properties supplied to the step:
{
  "parent": {
    "child": "value"
  }
}

JSON Patch reflecting the updates made to the properties in the step (that cannot be applied):
[{
  "op": "replace",
  "path": "/parent/child",
  "value": "new value"
}]

Patched original properties - that could not be saved because the project properties were modified outside this step:
{
  "parent": {
    "child": "new value"
  }
}

Current value of project properties (that the JSON Patch fails to apply to):
{}

Please resolve this conflict manually and correct the project properties via the `opschain project set-properties` command. If applicable, retry the change to complete any remaining steps.
```

Use the four JSON documents from the change log, and your knowledge of the actions being performed by the conflicting steps, to:

1. construct a version of the properties that incorporates the required updates
2. use the CLI to manually update the relevant properties.

If there are no further steps in the change to run, there is no need to retry the failed change and you can continue using OpsChain as normal.

If there are further steps in the change to run, and the failed step is idempotent, you can use the `opschain change retry` command to restart the change from the failed step. **It is important to note that OpsChain will re-run the failed step in its entirety.**

If there are further steps in the change to run, and the failed step is NOT idempotent, you will need to create change(s) to perform the incomplete actions.

### File properties

OpsChain file properties are written to the working directory prior to the step action being initiated. Any property under `opschain.files` is interpreted as a file property and will be written to disk.

```json
{
  "opschain": {
    "files": {
      "/full/path/to/file1.txt": {
        "mode": "0600",
        "content": "contents of the file"
      },
      "~/path/to/file2.json": {
        "content": {
          "json": "file",
          "values": "here"
        },
        "format": "json"
      }
    }
  }
}
```

Each file property key is an absolute path (or will be [expanded](https://docs.ruby-lang.org/en/2.7.0/File.html#method-c-expand_path) to one) and represents the location the file will be written to. Each file property value can include the following attributes:

| Attribute | Description                                  |
| :-------- | :------------------------------------------- |
| mode      | The file mode, specified in octal (optional) |
| content   | The content of the file (optional)           |
| format    | The format of the file (optional)            |

#### File formats

The file format attribute provides OpsChain with information on how to serialise the file content (for storage in OpsChain properties), and de-serialise the content (before writing to the Opschain runner filesystem). The following formats are currently supported:

- base64
- json
- raw (default)

_Please contact LimePoint if you require other file formats._

#### Storing & removing files

The project or environment properties can be edited directly to add, edit or remove file properties (using a combination of a text editor, the `show-properties` and `set-properties` commands). In addition, OpsChain enables you to store and remove files from within your actions.

##### Project file properties

To store a file in the project properties

```ruby
  OpsChain.project.store_file!('/file/to/store.txt')
```

To remove a file from the project properties

```ruby
  OpsChain.project.remove_file!('/file/to/store.txt')
```

##### Environment file properties

To store a file in the environment properties

```ruby
  OpsChain.environment.store_file!('/file/to/store.txt')
```

To remove a file from the environment properties

```ruby
  OpsChain.environment.remove_file!('/file/to/store.txt')
```

##### Optional file format

The `store_file!` method accepts an optional `format:` parameter, allowing you to specify the [file format](#file-formats) OpsChain should use when adding the file into the file properties. For example:

```ruby
  OpsChain.environment.store_file!('/file/to/store.txt', format: :base64)
```

##### Storing files examples

Examples of storing files can be seen in the [Ansible example](https://github.com/LimePoint/opschain-examples-ansible).

- The `save_known_hosts` [action](concepts.md#action) in [`actions.rb`](https://github.com/LimePoint/opschain-examples-ansible/blob/master/actions.rb) uses this feature to store the SSH `known_hosts` file in the environment properties - to ensure the host is [trusted](https://en.wikipedia.org/wiki/Trust_on_first_use) in future steps and actions

### Environment variables

OpsChain environment variable properties allow you to configure the process environment prior to running your [step](concepts.md#step) [actions](concepts.md#action). Any property under `opschain.env` will be interpreted as an environment variable property.

```json
{
  "opschain": {
    "env": {
      "VARIABLE_NAME": "variable value",
      "DIFF_VARIABLE": "different variable value"
    }
  }
}
```

#### Action environment

Each [step](concepts.md#step) [action](concepts.md#action) is executed using the `opschain-action` command. This will define an environment variable for each of the OpsChain environment variable properties prior to executing the action.

##### Bundler credentials

[Bundler Gem source credentials can be configured via environment variables](https://bundler.io/v1.16/bundle_config.html#CREDENTIALS-FOR-GEM-SOURCES). Defining an OpsChain environment variable with the relevant username/password (e.g. `"BUNDLE_BITBUCKET__ORG": "username:password"`) will make this available to bundler.

#### Setting environment variables example

An example of setting environment variables can be seen in the [Ansible example](https://github.com/LimePoint/opschain-examples-ansible). The [`project_properties.json`](https://github.com/LimePoint/opschain-examples-ansible/blob/master/project_properties.json) contains the credentials to be able to successfully login to your AWS account.

### Project / environment configuration

The `opschain.config` section of the properties allow you to change the OpsChain configuration for the project or environment the properties are assigned to. The following configuration options can be set in your properties JSON:

```json
{
  "opschain": {
    "config": {
      "change_log_retention_days": -- see table below --,
      "event_retention_days": -- see table below --,
      "environments": {
        "allow_parallel_changes": -- see table below --
      }
    }
  }
}
```

_Note: Configuration options within `opschain.config.environments` can only be set in project properties and are applicable to all environments within the project. All other configuration options can be set at project or environment level, with environment configuration overriding project configuration._

| Configuration Option      | Description                                                                                                                                                                                             | Default value                                |
|:--------------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:---------------------------------------------|
| change_log_retention_days | The number of days to retain change logs. See [change log retention](../../operations/maintenance/data_retention.md#change-log-retention) for more information.                                         | unset, OpsChain will retain all change logs. |
| event_retention_days      | The number of days to retain events. See [event retention](../../operations/maintenance/data_retention.md#event-retention) for more information                                                                          | unset, OpsChain will retain all events.       |
| allow_parallel_changes    | For a given project, allow multiple changes to run within a single environment. See [change execution options](changes.md#change-execution-options) in the changes reference guide for more information | false                                        |

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
