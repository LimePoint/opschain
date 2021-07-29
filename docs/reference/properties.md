# OpsChain Properties Guide

The OpsChain Properties framework provides a secure, versioned location to store:
* key value pairs
* environment variables and values (that will be available in the Unix environment running a change action)
* files (that will be written to the working directory before running a change action).

OpsChain Properties are encrypted prior to being written to disk to ensure they are inaccessible to anyone accessing the underlying OpsChain database.

OpsChain maintains a complete version history of each change made to the OpsChain Properties JSON, enabling you to view and compare the properties used for any change.

After following this guide you should understand:
- how to import OpsChain Properties using the CLI
- how to view OpsChain Properties from the CLI and API server
- the various types of values that can be stored in OpsChain Properties

## Loading Properties

The OpsChain CLI allows you to set properties at the project or environment level. The CLI can import JSON files from the `cli-files` directory within the OpsChain repository. First create a JSON file in the cli-files directory. Eg.

```bash
$ cat << EOF > cli-files/my_opschain_properties.json
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
$ opschain project properties-set --project_id $project_id --file_path cli-files/my_opschain_properties.json --confirm
```

or environment:

```bash
$ opschain environment properties-set --project_id $project_id --environment_code $environment_code --file_path cli-files/my_opschain_properties.json --confirm
```

Notes:
1. The values available in an action (via `OpsChain.properties`) are the result of a deep merge of the [change's](concepts.md#change) [project](concepts.md#project) and [environment](concepts.md#environment) level properties. If a property exists at [project](concepts.md#project) and [environment](concepts.md#environment) level, the [environment](concepts.md#environment) value will override the [project](concepts.md#project) value.
2. Any arrays in the [project](concepts.md#project) or [environment](concepts.md#environment) properties will be overwritten during a deep merge (use JSON objects with keys instead to ensure they are merged)

## Viewing Properties

The OpsChain CLI allows you to view the stored properties:

```bash
$ opschain project properties-show --project_id $project_id
$ opschain environment properties-show --project_id $project_id --environment_code $environment_code
```

The CLI does not currently support viewing prior versions of the properties. To do this you will need to interact directly with the OpsChain API server. The project API location:

```
http://<host>:3000/projects/PROJECT_ID
```

The environment API location (the link below will respond with all environments for the project specified - review the output for the environment of interest):

```
http://<host>:3000/environments?project_id=PROJECT_ID
```

The relevant API response will contain a link to the properties associated with that object in `/data/relationships/properties/links/related`. This will return the current properties values, including the current version number (in `/data/attributes/version`). To request a different version of the properties, simply append `/versions/VERSION_NUMBER` to the url. Eg.

```
http://<host>>:3000/properties/PROPERTIES_ID/versions/7
```

## Properties Content

### Key Value Pairs

You can use OpsChain key value properties from anywhere in your `actions.rb` to provide environment (or project) specific values to your resource actions. Eg.

```ruby
database :my_database do
  host OpsChain.properties.database.host_name
  source_path OpsChain.properties.database.source_path
end
```

#### Read Only properties

Properties will behave like a [Hashie Mash](https://github.com/hashie/hashie#mash)[^1].

Properties can be accessed using dot or square bracket notation with string or symbol keys. These examples are equivalent:
```ruby
require 'opschain'

OpsChain.properties.server.setting
OpsChain.properties[:server][:setting]
OpsChain.properties['server']['setting']
```

You will not be able to use dot notation to access a property with the same name as a method on the properties object (for example `keys`). In this case you must use square bracket notation instead.

The values available from `OpsChain.properties` are the result of a merge of the Change's Project and Environment level properties. If a property exists at Project and Environment level, the Environment value will override the Project value.

#### Modifiable Properties

In addition to the read only values available from `OpsChain.properties`, the Project and Environment specific properties are available via:
```ruby
OpsChain.project.properties
OpsChain.environment.properties
```

These are exposed to allow you to add, remove and update properties, with any modifications saved on [step](concepts.md#step) completion. The modified project and environment properties are then available to any subsequent [steps](concepts.md#step) or [changes](concepts.md#change).

##### Creating / Updating Properties Within Actions

The following code will set the Project `server_name` property, creating or updating it as applicable:

```ruby
OpsChain.project.properties.server_name = 'server1.limepoint.com'
```

_Note. As the Properties behave like a Hashie::Mash, creating multiple levels of property nesting in a single command requires you to supply a hash as the value. Eg._

```ruby
OpsChain.project.properties.parent = { child: { grandchild: 'value' } }
```

Once created, nested properties can be updated as follows:

```ruby
OpsChain.project.properties.parent.child.grandchild = 'new value'
```

##### Deleting Properties

To delete the grandchild property described above, use the following command:

```ruby
OpsChain.project.properties.parent.child.delete(:grandchild)
```

_Note. This would leave the parent and child keys in the project properties. To delete the entire tree, use the following command:_

```ruby
OpsChain.project.properties.delete(:parent)
```

##### Example

An example of setting Properties can be seen in the [Confluent Example](https://github.com/LimePoint/opschain-examples-confluent). The `provision` [action](concepts.md#action) in [`actions.rb`](https://github.com/LimePoint/opschain-examples-confluent/blob/master/actions.rb) modifies the environment properties to change settings for broker1.

### File Properties

OpsChain File properties are written to the working directory prior to the step action being initiated. Any property under `opschain.files` is interpreted as a file property and will be written to disk.

```
{
  "opschain": {
    "files": {
      "/full/path/to/file1.txt": {
        "mode": "0600",
        "content": "contents of the file"
      },
      "/full/path/to/file2.json": {
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

Each file property key is an absolute path and represents the location the file will be written to. Each file property value can include the following attributes:

| Attribute | Description |
| :-------- | :---------- |
| mode | The file mode, specified in octal (optional) |
| content | The content of the file (optional) |
| format | The format of the file (optional) |

_Note: The example above shows the two file formats OpsChain currently supports - JSON files, and raw (unparsed) file content. Please contact LimePoint if you require additional file format support._

### Storing & Removing Files

The project or environment properties can be edited directly to add, edit or remove file properties (using a combination of a text editor, the `properties-show` and `properties-set` commands). In addition, OpsChain enables you to store and remove files from within your actions.

#### Project File Properties

To store a file in the project properties
```ruby
  OpsChain.project.store_file!('/file/to/store.txt')
```

To remove a file from the project properties
```ruby
  OpsChain.project.remove_file!('/file/to/store.txt')
```

#### Environment File Properties

To store a file in the environment properties
```ruby
  OpsChain.environment.store_file!('/file/to/store.txt')
```

To remove a file from the environment properties
```ruby
  OpsChain.environment.remove_file!('/file/to/store.txt')
```


#### Example

An example of setting Files can be seen in the [Confluent Example](https://github.com/LimePoint/opschain-examples-confluent).
- The `generate_keys` [action](concepts.md#action) in [`actions.rb`](https://github.com/LimePoint/opschain-examples-confluent/blob/master/actions.rb) uses this feature to store generated SSH keys in the environment properties (for use later when building the base image for the Confluent servers.
- The `provision` [action](concepts.md#action) in [`actions.rb`](https://github.com/LimePoint/opschain-examples-confluent/blob/master/actions.rb) uses this feature to store the terraform.tfstate file in the environment properties (to ensure the terraform state is available to future runs)

### Environment Variables

OpsChain Environment variable properties allow you to configure the process environment prior to running your [step](concepts.md#step) [actions](concepts.md#action). Any property under `opschain.env` will be interpreted as an environment variable property.

```
{
  "opschain": {
    "env": {
      "VARIABLE_NAME": "variable value",
      "DIFF_VARIABLE": "different variable value"
    }
  }
}
```

#### Action Environment

Each [step](concepts.md#step) [action](concepts.md#action) is executed using the `opschain-action` command. This will define an environment variable for each of the OpsChain environment variable properties prior to executing the action.

##### Bundler Credentials

[Bundler gem source credentials can be configured via environment variables](https://bundler.io/v1.16/bundle_config.html#CREDENTIALS-FOR-GEM-SOURCES). Defining an OpsChain environment variable with the relevant username/password (eg. `"BUNDLE_BITBUCKET__ORG": "username:password"`) will make this available to bundler.

#### Example

An example of setting Environment Variables can be seen in the [Confluent Example](https://github.com/LimePoint/opschain-examples-confluent). The [`environment_properties.json`](https://github.com/LimePoint/opschain-examples-confluent/blob/master/environment_properties.json) includes the `TF_IN_AUTOMATION` environment variable to instruct Terraform that it is running in non-human interactive mode.

# Licence & Authors
- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../../LICENCE)
