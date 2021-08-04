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

## OpsChain properties

Within each action, OpsChain properties are available via `OpsChain.properties` (which will behave like a [Hashie Mash](https://github.com/hashie/hashie#mash)[^1])). The values available are the result of a deep merge of the [change's](concepts.md#change) [project's Git repository](project_git_repositories.md) properties with the [project](concepts.md#project) and [environment](concepts.md#environment) level properties. If a property exists at multiple levels, project values will override repository values and environment values will override project and repository values.

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

## Storage options

### Git repository

OpsChain will look for the following files in your project's Git repository:

- `.opschain/properties.json`
- `.opschain/properties.toml`
- `.opschain/properties.yaml`

If more than one of these files exist in the repository, they will be merged together in the order listed above. Properties defined in properties.yaml will override properties defined in properties.toml and properties.json. Properties defined in properties.toml will override properties defined in properties.json. Within each action, the result of merging these files will be available via `OpsChain.repository.properties`.

#### Notes

1. The repository properties are read only within each action (as OpsChain cannot modify the underling Git repository to store any changes).
2. Running `opschain-action -AT` from within your Git repository will cause the properties files to be validated. If the schema or structure of the files is invalid, explanatory exceptions will be raised. See the [Docker development environment](../docker_development_environment.md) guide for more information.

### Database

Properties stored in the database are encrypted prior to being written to disk such that they are encrypted-at-rest. Within each action, project properties are available via `OpsChain.project.properties`. Similarly environment properties are available via `OpsChain.environment.properties`.

#### Loading properties

The OpsChain CLI allows you to set properties at the project or environment level. The CLI can import JSON files from the `cli-files` directory within the OpsChain repository. First create a JSON file in the cli-files directory. E.g.

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
opschain project set-properties --project-code <project code> --file-path cli-files/my_opschain_properties.json --confirm
```

or environment:

```bash
opschain environment set-properties --project-code <project code> --environment-code <environment_code> --file-path cli-files/my_opschain_properties.json --confirm
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
http://<host>:3000/environments?project-code=<project code>
```

The relevant API response will contain a link to the properties associated with that object in `/data/relationships/properties/links/related`. This will return the current properties values, including the current version number (in `/data/attributes/version`). To request a different version of the properties, simply append `/versions/VERSION_NUMBER` to the url. E.g.

```text
http://<host>>:3000/properties/PROPERTIES_ID/versions/7
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

Attribute | Description
:-------- | :-------------------------------------------
mode      | The file mode, specified in octal (optional)
content   | The content of the file (optional)
format    | The format of the file (optional)

#### File formats

The file format attribute provides OpsChain with information on how to serialise the file content (for storage in OpsChain properties), and de-serialise the content (before writing to the Opschain runner filesystem). The following formats are currently supported:

- base64
- json
- raw (default)

_Please contact LimePoint if you require other file formats._

### Storing & removing files

The project or environment properties can be edited directly to add, edit or remove file properties (using a combination of a text editor, the `show-properties` and `set-properties` commands). In addition, OpsChain enables you to store and remove files from within your actions.

#### Project file properties

To store a file in the project properties

```ruby
  OpsChain.project.store_file!('/file/to/store.txt')
```

To remove a file from the project properties

```ruby
  OpsChain.project.remove_file!('/file/to/store.txt')
```

#### Environment file properties

To store a file in the environment properties

```ruby
  OpsChain.environment.store_file!('/file/to/store.txt')
```

To remove a file from the environment properties

```ruby
  OpsChain.environment.remove_file!('/file/to/store.txt')
```

#### Optional file format

The `store_file!` method accepts an optional `format:` parameter, allowing you to specify the [file format](#file-formats) OpsChain should use when adding the file into the file properties. For example:

```ruby
  OpsChain.environment.store_file!('/file/to/store.txt', format: :base64)
```

#### Storing files examples

Examples of storing files can be seen in the [Confluent example](https://github.com/LimePoint/opschain-examples-confluent).

- The `generate_keys` [action](concepts.md#action) in [`actions.rb`](https://github.com/LimePoint/opschain-examples-confluent/blob/master/actions.rb) uses this feature to store generated SSH keys in the environment properties (for use later when building the base image for the Confluent servers
- The `provision` [action](concepts.md#action) in [`actions.rb`](https://github.com/LimePoint/opschain-examples-confluent/blob/master/actions.rb) uses this feature to store the terraform.tfstate file in the environment properties (to ensure the terraform state is available to future runs)

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

[Bundler gem source credentials can be configured via environment variables](https://bundler.io/v1.16/bundle_config.html#CREDENTIALS-FOR-GEM-SOURCES). Defining an OpsChain environment variable with the relevant username/password (e.g. `"BUNDLE_BITBUCKET__ORG": "username:password"`) will make this available to bundler.

#### Setting environment variables example

An example of setting environment variables can be seen in the [Confluent example](https://github.com/LimePoint/opschain-examples-confluent). The [`environment_properties.json`](https://github.com/LimePoint/opschain-examples-confluent/blob/master/environment_properties.json) includes the `TF_IN_AUTOMATION` environment variable to instruct Terraform that it is running in non-human interactive mode.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../../LICENCE)
