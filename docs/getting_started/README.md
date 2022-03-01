# Getting started

[OpsChain](https://opschain.io) was developed to address the problem of managing change in a consistent and uniform way across on-premise, cloud, modern, and legacy platforms. Our objective is to unify people, process, and technology in order to simplify and reduce the operational complexities and costs of running and operating modern enterprise applications and systems in today's world.

[Learn more about how OpsChain can help your organisation.](https://opschain.io/why)

The following example will allow you to explore some of the features of OpsChain and how you can use it to simplify, track and manage change in your organisation.

## Install OpsChain

Follow the getting started [installation guide](installation.md) to install and configure OpsChain on your machine.

## Explore OpsChain

The OpsChain [concepts guide](../reference/concepts/concepts.md) describes the terminology used throughout this guide. You may find it helpful to review prior to continuing.

### Setup OpsChain to run sample changes

Let's create an OpsChain `Website` project, consisting of `Test` and `Production` environments, so we can demonstrate using OpsChain to manage a simple website. We'll use an example Git repository containing configuration and infrastructure changes that we can deploy with OpsChain. After deploying the changes, we'll use Opschain to track and report on the changes deployed to our website.

#### Create an OpsChain project

First, create an OpsChain [project](../reference/concepts/concepts.md#project) to contain the configuration and actions to apply to our [environments](../reference/concepts/concepts.md#environment).

```bash
opschain project create --code web --name Website --description 'Public facing website infrastructure' --confirm
```

##### Set the project Git remote

Add the `opschain-getting-started` Git repository as a [remote](https://git-scm.com/book/en/v2/Git-Basics-Working-with-Remotes) for your new project:

```bash
# Note: to avoid potentially storing the repository credentials in the shell history the `--url` argument can be omitted and filled in when prompted
$ opschain project set-git-remote \
  --project-code web \
  --name origin \
  --url 'https://{username}:{personal access token}@github.com/LimePoint/opschain-getting-started.git' \
  --confirm
```

_Notes:_

1. _Use the GitHub personal access token you created while following the [installation guide](installation.md#create-a-github-personal-access-token)._
2. _If your token contains special characters, they must be [URL encoded](https://www.w3schools.com/tags/ref_urlencode.asp) in order to use them in the URL parameter._

#### Create OpsChain environments

Create the logical [environments](../reference/concepts/concepts.md#environment) where OpsChain will manage change.

```bash
opschain environment create --project-code web --code test --name 'Test' --description 'optional description' --confirm
opschain environment create --project-code web --code prod --name 'Production' --description '' --confirm
```

#### Configure a default project

OpsChain allows you to configure environment variables that will supply default values to the CLI. As the remainder of this guide utilises the `web` project, lets configure it as the default for our current session:

```bash
export opschain_projectCode=web
```

_Note: This setting can be overridden by specifying a `--project-code` explicitly on the command line._

#### Create OpsChain properties

OpsChain allows you to define [properties](../reference/concepts/properties.md) that will be available to running changes. These can be key value pairs, environment variables and even secure files. Create a sample project and environment properties JSON by copy and pasting the commands below.

```bash
cat << EOF > cli-files/project_properties.json
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
cat << EOF > cli-files/prod_properties.json
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
opschain project set-properties --file-path cli-files/project_properties.json --confirm
opschain environment set-properties --environment-code prod --file-path cli-files/prod_properties.json --confirm
```

The project properties provide default values to use when running changes in any environment in the project. The production environment properties override these defaults with production specific values.

### Running OpsChain changes

Our project team utilise a custom `artifact_deploy.sh` script to deploy their website's WAR file to the target web server. They've found it difficult to keep track of:

- who is using the script
- what version of the WAR file they deploy
- which instance of the project website they deployed to
- when the deployment occurred

To enable the team to control access to the script, and provide auditability of its use, the team has wrapped their existing script inside an OpsChain `deploy_war` action.

#### Run your first change

The sample Git repository includes the team's `artifact_deploy.sh` script, and a `deploy_war` action to execute it from OpsChain. Lets use the OpsChain CLI in interactive mode to run the script in OpsChain:

```bash
opschain change create
```

Choose/enter the following parameters:

```text
Environment: Test
Git rev: origin/master
Action (optional): deploy_war
Create this change? Yes
```

An informational table and step tree will be displayed. Each step in an OpsChain change is executed within its Docker container, ensuring its isolation from the host system and other running changes.

#### View change logs

Once the change is complete, copy the change ID displayed in the `opschain change create` table output and use it to view the logs from your change.

```bash
test_change_id=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
opschain change show-logs --change-id $test_change_id
```

The beginning of the log shows the output from Docker as it builds the OpsChain runner image for the `deploy_war` action. After the build output you will see the action output. Note the output includes:

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
cat << EOF > cli-files/prod_change_metadata.json
{
  "change_request": "CR921",
  "approver": "A. Manager"
}
EOF
```

#### Run the production change

Rather than use the CLI in interactive mode, lets create the production change by supplying the parameters on the command line.

```bash
opschain change create --environment-code prod --action deploy_war --git-rev origin/master --metadata-path cli-files/prod_change_metadata.json --confirm
```

The same change action and git revision are provided, ensuring the change applied to the test environment is replicated in production. The only difference to the change we created in test, is the target environment and the inclusion of optional metadata.

#### View the production change list

To `change list` command allows you to view the list of changes applied to an environment. The inclusion of metadata in the list helps identify specific changes.

```bash
opschain change list --environment-code prod
```

Looking at the list, our project team can now easily see who deployed a WAR to production, when they deployed it, and even who approved the deployment!

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
opschain project show-properties > cli-files/project_properties.json
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

_Note: Be sure to remove the first line containing the project information._

Replace the project properties with the contents of the updated JSON.

```bash
opschain project set-properties --file-path cli-files/project_properties.json --confirm
```

Create a new change to deploy the WAR to the test environment and view the change logs:

```bash
opschain change create --environment-code test --action deploy_war --git-rev origin/master --confirm
opschain change show-logs --change-id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

Notice how the updated WAR file has been used when running the `artifact_deploy.sh` script.

### Combining tools

With OpsChain's DSL and Ruby integration you can develop actions to do almost anything. Take advantage of the best tool for every task and combine tools to manage change in the way that best suits your business. Imagine the web server needs to be placed into maintenance mode prior to deploying the new WAR file, then restored to active service afterwards. OpsChain allows you to combine these steps into a single automated change. Lets run a multi-step change to see how OpsChain manages this process:

```bash
opschain change create --environment-code test --action deploy_in_maintenance_mode --git-rev origin/master --confirm
```

Notice how the `deploy_war` action is performed in between the enable and disable maintenance mode actions.

As you can see, once the OpsChain actions have been developed, your team can use OpsChain's simple interface to execute any sequence of tasks, with any underlying tools!

### Managing your infrastructure

Our project team uses a cloud service provider for their webserver hosting. To save money, the team shuts down the test instance every evening, and starts it again each morning. Rather than teach the team how to use the cloud providers CLI, they've wrapped the start and stop instance commands into `stop_instance` and `start_instance` actions. Try creating a change to stop the test instance:

```bash
opschain change create --environment-code test --action stop_instance --git-rev origin/master --confirm
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
opschain automated-change create --environment-code test --git-rev origin/master --action stop_instance --cron-schedule '0 0 20 * * *' --new-commits-only=false --repeat --confirm
opschain automated-change create --environment-code test --git-rev origin/master --action start_instance --cron-schedule '0 0 6 * * *' --new-commits-only=false --repeat --confirm
```

Now the test instance will be stopped each evening at 8pm (in the OpsChain server's timezone) and started each morning at 6am.

##### View the configured rules

To view the newly configured rules, use the `automated-change list` command.

```bash
opschain automated-change list --environment-code test
```

#### Git commits

Note the `--new-commits-only=false` parameter used in the rule creation commands above. This instructs OpsChain to always create a change on the cron schedule. If `--new-commits-only=true` were used instead, OpsChain would continue to follow the specified cron schedule, but would only create a change if new commits were present in the project Git repository. With this feature, OpsChain can be used to automatically promote code changes on a schedule that suits your team. For example, you could configure a rule to automatically promote new commits in `master` to a test environment. Have your developers work in feature branches and their merge to `master` will also promote the code to test - at a time that suits your team, or straight away. See the [automated change rules guide](../automated_changes.md) for more details.

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
