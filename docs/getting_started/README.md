# Getting started

[OpsChain](https://opschain.io) was developed to address the problem of managing change in a consistent and uniform way across on-premise, cloud, modern, and legacy platforms. Our objective is to unify people, process, and technology in order to simplify and reduce the operational complexities and costs of running and operating modern enterprise applications and systems in today's world.

[Learn more about how OpsChain can help your organisation.](https://opschain.io/why)

The following example will allow you to explore some of the features of OpsChain and how you can use it to simplify, track and manage change in your organisation. You will need access to an OpsChain API server, either installed locally or network accessible.

## Install the OpsChain server

If you do not have access to an OpsChain API server, follow the [installation guide](../operations/installation.md) to install and configure OpsChain on your machine.

## Install the OpsChain CLI

The OpsChain CLI allows you to interact with the OpsChain API server and is required to run the examples in this guide. If you followed the OpsChain server [installation guide](../operations/installation.md) then you can skip this section as it has already covered these steps.

The latest version of the CLI can be downloaded from the [`opschain` repository](https://github.com/LimePoint/opschain/releases).

Download the release for your platform. Once downloaded, we suggest renaming the binary to `opschain` (e.g. `mv opschain-* opschain`), and it will need to be made executable if using Linux, macOS, or WSL - e.g. `chmod +x opschain`.

We suggest putting the executable somewhere on your `PATH` to allow it to be executed without specifying the full path - e.g. `sudo mv opschain /usr/local/bin/opschain`.

_Note: On macOS you may need to trust the OpsChain CLI binary as it is not currently signed. See [the Apple documentation](https://support.apple.com/en-au/guide/mac-help/mh40616/mac) for details._

### Configure the OpsChain CLI

Create a `.opschainrc` in your home directory (e.g. `~/.opschainrc` on Linux, macOS, or WSL) based on the [example](/config_file_examples/opschainrc.example) - be sure to update the `apiBaseUrl` to point to your OpsChain server installation, and the `username` and `password` configuration for your user account. On Windows - not within WSL - the configuration file should be placed in the `USERPROFILE` directory. See the [CLI configuration locations](../reference/cli.md#cli-configuration-locations) guide if you would like to learn more.

_Note: If you create a `.opschainrc` file in your current working directory, it will be used instead of the version in your home directory._

Run the `opschain info` subcommand to verify that the server is accessible - it will include the server version if it is able to connect to the OpsChain server.

If you would like to learn more about the CLI, see the [CLI reference guide](../reference/cli.md).

## Explore OpsChain

The OpsChain [concepts guide](../reference/concepts/concepts.md) describes the terminology used throughout this guide. You may find it helpful to review prior to continuing - alternatively it is designed as a reference that you can revisit at any time.

### Setup OpsChain to run a simple sample change

Let's create an OpsChain `Website` project. Projects are used to organise environments and changes - a project contains many environments, and changes can be applied to these environments. Projects allow a number of environments to share configuration and GitOps definitions.

OpsChain manages change. The structure of your changes is entirely customisable, and will be influenced by the tools you use with OpsChain - you may structure your changes using "desired state" techniques, or by applying explicit actions (e.g. upgrading a single package in response to a security vulnerability). OpsChain supports both patterns.

We will use our new `Website` project to run a simple OpsChain change. Later in this guide we will use it to run through a more advanced example showing more of OpsChain's features.

#### Create an OpsChain project

Create the new project by using the `opschain project create` command, as shown below. If you wish to learn more about an OpsChain CLI command (or subcommand), add the `--help` argument, e.g. `opschain project create --help`.

```bash
opschain project create --code web --name Website --description 'Public facing website infrastructure' --confirm
```

##### Add a project Git remote

OpsChain's uses Git to manage the configuration and code associated with changes. Let's start by adding a [Git remote](../reference/concepts/concepts.md#git-remote) to our project. It contains some sample changes that we will use in this guide.

Add the `opschain-getting-started` Git repository as a Git remote for your new project:

```bash
# Note: to avoid potentially storing the repository credentials in the shell history the `--user` and `--password` arguments can be omitted and filled in when prompted
# Option 1: Using password authentication:
$ opschain project add-git-remote \
  --project-code web \
  --name origin \
  --user '{username}' \
  --password '{password / personal access token}' \
  --url 'https://github.com/LimePoint/opschain-getting-started.git' \
  --ssh-key-file '' \
  --confirm
# Option 2: Using SSH authentication:
$ opschain project add-git-remote \
  --project-code web \
  --name origin \
  --ssh-key-file ./path/to/private/key \
  --url 'git@github.com:LimePoint/opschain-getting-started.git' \
  --user '' \
  --password '' \
  --confirm
```

_Note: You can use the GitHub personal access token you created while following the [installation guide](../operations/installation.md#create-a-github-personal-access-token) if using a local OpsChain install._

#### Create an OpsChain environment

An OpsChain change must be targeted to an [environment](../reference/concepts/concepts.md#environment). OpsChain's concept of environments allows configuration to be managed on a per-environment level - overriding configuration from the project.

The `opschain environment create` subcommand can be used to create a sample `Test` environment, where we will run our first change:

```bash
opschain environment create --project-code web --code test --name 'Test' --description 'optional description' --confirm
```

### Create and run a change

The `opschain change create` subcommand is used to run a change within an environment (which itself exists within a project).

The sample Git remote that was added earlier includes a very simple `hello_world` action that we can use to create our first change:

```bash
opschain change create
```

Choose/enter the following parameters:

```text
Project: Website
Environment: Test
Git remote name: origin
Git rev: master
Action (optional): hello_world
Create this change? Yes
```

_Note: these parameters can be provided as arguments too, run `opschain change create --help` to learn more._

Once the parameters have been entered, the change will be created and started, and the OpsChain CLI will report on the status of the change as it progresses.

Your very first OpsChain change will likely take several minutes to execute as OpsChain needs to perform additional processes internally.

The CLI will report on the status of the change as it progresses, and will exit once the change has completed.

### View change logs

Whenever required, the logs from the change execution can be viewed by using the `opschain change show-logs` subcommand.

Copy the change ID displayed in the `opschain change create` table output and use it to view the logs from your change.

```bash
opschain change show-logs --change-id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

Our very simple first change has just logged `Hello world` - we can also see information about the change as OpsChain processed it.

_Note: If you wish to view the logs as your change executes, specify the `--follow-logs` option when [creating the change](#create-and-run-a-change). This option can also be supplied to the `opschain change show-logs` command to follow an existing change._

### Viewing all changes executed in an environment

OpsChain helps teams work together to manage change. One of the features that OpsChain provides to that end is to keep track of which changes have already been executed in an environment.

Use the `opschain change list` command to list the changes executed in the `Test` environment:

```bash
opschain change list --project-code web --environment-code test
```

The resulting table will list all the changes run in the `Test` environment, in particular the change we just ran. The table doesn't provide much value with a single change, however in a team environment where multiple users are running changes, the change list allows users to know what changes their team have executed.

### Setup OpsChain to run more advanced sample changes

To show some of the more advanced features of OpsChain, we will run another OpsChain change, using a different [action](../reference/concepts/concepts.md#action), which gives a more realistic scenario and leverages more OpsChain features.

#### Add a second OpsChain environment

Add another OpsChain environment, using the `opschain environment create` command again, so that we promote our change from `Test` to `Production`:

```bash
opschain environment create --project-code web --code prod --name 'Production' --description '' --confirm
```

#### Configure a default project

OpsChain allows you to configure environment variables that will supply default values to the CLI. As the remainder of this guide utilises the `web` project, lets configure it as the default for our current session:

```bash
export opschain_projectCode=web
```

_Note: This setting can be overridden by specifying a `--project-code` explicitly on the command line. It can also be set in your [CLI configuration](../reference/cli.md#opschain-cli-configuration-settings) if you are always working in the same project._

#### Create OpsChain properties

OpsChain allows you to define [properties](../reference/concepts/properties.md) that will be available to running changes. These can be key value pairs, environment variables and even secure files. Create a sample project and environment properties JSON by copy and pasting the commands below.

```bash
cat << EOF > project_properties.json
{
  "opschain": {
    "env": {
      "ACCESS_KEY_ID": "---> non-production access key id",
      "SECRET_ACCESS_KEY": "---> non-production secret access key"
    }
  },
  "instance_id": "i-0123abc45de6fg789"
}
EOF
cat << EOF > prod_properties.json
{
  "opschain": {
    "env": {
      "ACCESS_KEY_ID": "---> Production access key id",
      "SECRET_ACCESS_KEY": "---> Production secret access key"
    }
  },
  "instance_id": "i-9876abc54de6fg321"
}
EOF
```

Use these JSON files to set project and environment specific properties.

```bash
opschain project set-properties --file-path project_properties.json --confirm
opschain environment set-properties --environment-code prod --file-path prod_properties.json --confirm
```

The project properties provide default values to use when running changes in any environment in the project. The production environment properties override these defaults with production specific values.

### Advanced change example

Our project team utilise a custom `artifact_deploy.sh` script to deploy their website's WAR file to the target web server. They've found it difficult to keep track of:

- who is using the script
- what version of the WAR file they deploy
- which instance of the project website they deployed to
- when the deployment occurred

To enable the team to control access to the script, and provide auditability of its use, the team has wrapped their existing script inside an OpsChain `deploy_war` action.

#### Run the `deploy_war` action via a change

The sample Git repository includes the team's `artifact_deploy.sh` script, and a `deploy_war` action to execute it from OpsChain. Execute the following command to create and run this change in `Test`:

```bash
opschain change create --environment-code test --git-remote-name origin --git-rev master --action deploy_war --confirm
```

An informational table and step tree will be displayed. Each step in an OpsChain change is executed within its own container, ensuring its isolation from the host system and other running changes.

#### View `deploy_war` change logs

Once the change is complete, copy the change ID displayed in the `opschain change create` table output and use it to view the logs from your change.

```bash
test_change_id=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
opschain change show-logs --change-id $test_change_id
```

The beginning of the log shows the output from the image builder as it builds the OpsChain runner image for the `deploy_war` action. After the build output you will see the action output. Note the output includes:

- contextual references to the project (`Website`) and environment name (`Test`) the change is running in
- a war file to deploy (more on this later)
- the `instance_id` value from the project properties

_Notes:_

1. _Contextual references need not be displayed in the logs and are displayed for example purposes only._
2. _In contrast to the simple actions used throughout this guide, various [example projects](../examples/README.md) are available to demonstrate how OpsChain can affect real change on local and cloud servers._

#### View change properties

When a change is executed, a point in time copy of the properties used by the change is stored with it. Use the `change show-properties` command to view the properties used by your change:

```bash
opschain change show-properties --change-id $test_change_id
```

You'll notice the properties look different to the JSON file you uploaded earlier. It includes a `war_file` property, containing the file name that was displayed in the change log. This property value can be found in the [`properties.json`](https://github.com/LimePoint/opschain-getting-started/blob/master/.opschain/properties.json) included in the sample repository.

To build the properties used by a change, OpsChain starts with the Git repository properties and merges the secure project and environment properties from the database into them.

### Promoting changes

Understanding which changes have been applied to each environment is a critical factor for ensuring system stability. Issues often arise when patch levels and/or code changes become out of sync between environments. OpsChain makes keeping track of changes simple by providing a complete audit trail of the changes that have been applied to each environment.

#### Change metadata

In addition to capturing the logs and properties used by each change, OpsChain allows additional metadata to be associated with a change. This metadata can then be used when reporting on and searching the change history (via the API). Create a sample metadata file to associate with the production change:

```bash
cat << EOF > prod_change_metadata.json
{
  "change_request": "CR921",
  "approver": "A. Manager"
}
EOF
```

#### Run the production change

Rather than use the CLI in interactive mode, lets create the production change by supplying the parameters on the command line.

```bash
opschain change create --environment-code prod --action deploy_war --git-remote-name origin --git-rev master --metadata-path prod_change_metadata.json --confirm
```

The same change action and git revision are provided, ensuring the change applied to the test environment is replicated in production. The only difference to the change we created in test, is the target environment and the inclusion of optional metadata.

#### View the production change list

The `change list` command allows you to view the list of changes applied to an environment.

```bash
opschain change list --environment-code prod
```

Looking at the list, you should be able to view the information about the [change you just created](#run-the-production-change), such as who deployed a WAR to production, when they deployed it, and the status of the change execution.

To view the metadata we associated with the production change, use the `change show` command.

```bash
opschain change show --change-id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

#### View the production logs and properties

Lets look at the logs from the production deployment and see how the production specific properties changed the deployment.

```bash
opschain change show-logs --change-id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx --follow
```

As you can see, the WAR file to deploy remained the same, but the target instance reflects the value from the `prod_properties.json`.

The `--follow` argument added here means that the OpsChain CLI will continue showing the logs from the change until it completes. If the change has already finished, the command works identically as if that argument was omitted.

#### Change the WAR file to deploy

As mentioned earlier, the war file to deploy is contained in the [`properties.json`](https://github.com/LimePoint/opschain-getting-started/blob/master/.opschain/properties.json) file in the project Git repository. Editing and committing the updated file would allow the war file name to be overridden. Alternatively, an override value for the `war_file` property can be added to the project or environment properties. Download the current project properties JSON:

```bash
opschain project show-properties > project_properties.json
```

Edit the file, adding the `war_file` property as follows:

```text
{
  "opschain": {
    "env": {
      "ACCESS_KEY_ID": "---> non-production access key id",
      "SECRET_ACCESS_KEY": "---> non-production secret access key"
    }
  },
  "instance_id": "i-0123abc45de6fg789",
  "war_file": "acme_website_v1.1.war"
}
```

Replace the project properties with the contents of the updated JSON.

```bash
opschain project set-properties --file-path project_properties.json --confirm
```

Create a new change to deploy the WAR to the test environment and watch the change logs as the change progresses:

```bash
opschain change create --environment-code test --action deploy_war --git-remote-name origin --git-rev master --confirm --follow-logs
```

Notice how the updated WAR file has been used when running the `artifact_deploy.sh` script.

### Combining tools

With OpsChain's DSL and Ruby integration you can develop actions to do almost anything. Take advantage of the best tool for every task and combine tools to manage change in the way that best suits your business. Imagine the web server needs to be placed into maintenance mode prior to deploying the new WAR file, then restored to active service afterwards. OpsChain allows you to combine these steps into a single automated change. Lets run a multi-step change to see how OpsChain manages this process:

```bash
opschain change create --environment-code test --action deploy_in_maintenance_mode --git-remote-name origin --git-rev master --confirm
```

Notice how the `deploy_war` action is performed in between the enable and disable maintenance mode actions.

As you can see, once the OpsChain actions have been developed, your team can use OpsChain's simple interface to execute any sequence of tasks, with any underlying tools!

### Managing your infrastructure

Our project team uses a cloud service provider for their webserver hosting. To save money, the team shuts down the test instance every evening, and starts it again each morning. Rather than teach the team how to use the cloud providers CLI, they've wrapped the start and stop instance commands into `stop_instance` and `start_instance` actions. Try creating a change to stop the test instance:

```bash
opschain change create --environment-code test --action stop_instance --git-remote-name origin --git-rev master --confirm
```

Note: The hypothetical cloud provider's CLI makes use of an `ACCESS_KEY_ID` and `SECRET_ACCESS_KEY` in the user's Linux environment to authorise CLI commands. As each action runs inside an isolated container, OpsChain allows you to define [environment variables](../reference/concepts/properties.md#environment-variables) in your properties that will automatically be set in the container before the action is executed.

```bash
opschain change show-logs --change-id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

Review the logs to see how the `ACCESS_KEY_ID` and a `SECRET_ACCESS_KEY` we included in the project properties JSON, have been used by the `stop_instance` action.

### Automated changes

In addition to creating changes manually, OpsChain allows changes to be created on a time schedule, and also in response to Git commits.

#### Time scheduling

Automated change rules accept a [cron expression](https://crontab.guru/) that provides a standard format for defining how often a change should be run.

##### Add automated change rules

To save the project team manual effort and enable them to consistently realise the cost savings of stopping their test instance overnight, lets configure some test environment rules, to execute `stop_instance` each evening, and `start_instance` each morning.

```bash
opschain automated-change create --environment-code test --git-remote-name origin --git-rev master --action stop_instance --cron-schedule '0 0 20 * * *' --new-commits-only=false --repeat --confirm
opschain automated-change create --environment-code test --git-remote-name origin --git-rev master --action start_instance --cron-schedule '0 0 6 * * *' --new-commits-only=false --repeat --confirm
```

Now the test instance will be stopped each evening at 8pm (in the OpsChain server's timezone) and started each morning at 6am.

##### View the configured rules

To view the newly configured rules, use the `automated-change list` command.

```bash
opschain automated-change list --environment-code test
```

#### Git commits

Note the `--new-commits-only=false` parameter used in the rule creation commands above. This instructs OpsChain to always create a change on the cron schedule. If `--new-commits-only=true` were used instead, OpsChain would continue to follow the specified cron schedule, but would only create a change if new commits were present in the project Git repository. With this feature, OpsChain can be used to automatically promote code changes on a schedule that suits your team. For example, you could configure a rule to automatically promote new commits in `master` to a test environment. Have your developers work in feature branches and their merge to `master` will also promote the code to test - at a time that suits your team, or straight away. See the [automated change rules guide](../reference/concepts/automated_changes.md) for more details.

### Output formats

The majority of OpsChain CLI commands accept an optional `--output` argument, allowing you to alter the format of the command's output. By outputting machine readable formats such as JSON or YAML, the CLI can be incorporated into automated pipelines as required. See the [OpsChain CLI reference](../reference/cli.md#opschain-cli-configuration-settings) for more information on how to configure the default output format(s) for the CLI.

## What to do next

### Learn more about OpsChain actions

Follow the [developer getting started guide](developer.md) and add more advanced actions to the sample project (this guide is targeted at readers with some software development experience, although it is not mandatory).

### Try more advanced examples

The [OpsChain examples](../examples/README.md) include a variety of tutorials and Git repository samples for you to explore.

### Review the reference documentation

The [reference documentation](../reference/README.md) provides in-depth descriptions of many of the features available in OpsChain.

### Review the REST API documentation

With your OpsChain server running, navigate to the [OpsChain REST API Documentation](http://localhost:3000/docs) to learn more about OpsChain's REST endpoints. Interacting directly with the OpsChain API server opens up more features and integration options than using the CLI alone.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
