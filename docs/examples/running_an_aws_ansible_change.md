# Running an AWS Ansible change

Run a change that:

1. creates an AWS nano EC2 instance.
2. installs and configures nginx on the instance.
3. deploys a simple welcome home page to be displayed when users connect to the instance with their browser.

It is based on the Ansible [getting started: writing your first playbook](https://www.ansible.com/blog/getting-started-writing-your-first-playbook) example.

After following this guide you should know how to:

- create a project and environment
- add a remote Git repository as a project remote
- understand how to provide a custom Dockerfile
- use OpsChain properties to configure the Runner environment

## Prerequisites

1. To run this example you will need an AWS account with permissions to

    - create EC2 instances
    - create security groups
    - create key pairs

    If you do not have an AWS account, Amazon provides an [AWS free tier](https://aws.amazon.com/free/) that (at the time of writing) is capable of running the example. _Please read the AWS Terms and Conditions as Amazon may change the Free Tier features._

2. The example uses features provided by the AWS CLI and will require you to provide an _AWS Access Key ID_ and _Secret Access Key_ to access AWS. Please see the [managing access keys](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey) documentation for further details.

## Create a project

Create a new project:

```bash
opschain project create --code ansible --name 'Demo Ansible Project' --description 'My Ansible project' --confirm
```

Verify that your new project appears in the list:

```bash
opschain project list
```

## Create an environment

Environments represent the logical infrastructure environments under a project (for example Development or Production).

Create a new environment:

```bash
opschain environment create --project-code ansible --code ansbl --name 'Ansible Environment' --description 'My Ansible environment' --confirm
```

Verify that your new environment appears in the list:

```bash
opschain environment list --project-code ansible
```

## Add the Ansible example as a remote to the project Git repository

Follow [adding a project Git repository as a remote](../reference/project_git_repositories.md#adding-a-project-git-repository-as-a-remote) using the [OpsChain Ansible example repository](https://github.com/LimePoint/opschain-examples-ansible) remote URL `https://username:password@github.com/LimePoint/opschain-examples-ansible.git`.

### Clone the repository

Clone the Ansible example repository onto your machine:

```bash
git clone https://{username}:{personal access token}@github.com/LimePoint/opschain-examples-ansible.git
cd opschain-examples-ansible
```

### Configure the AWS credentials

To enable the OpsChain Runner to access your AWS account, configure the [AWS environment variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html) in the runner. To do this, create the [environment variables](../reference/concepts/properties.md#environment-variables) as [properties](../reference/concepts/properties.md) linked to the `Ansible Environment`.

1. Using the editor of your choice, open `project_properties.json` and insert your AWS Access Key ID and Secret Access Key. _Note: The AMI image used to create the EC2 instance for this example is associated with the us-west-2 region. For this reason, please do not alter the AWS_DEFAULT_REGION environment variable._

2. Import the project properties:

    ```bash
    opschain project set-properties --project-code ansible --file-path project_properties.json --confirm
    ```

    _Note: If required, your AWS credentials can be stored at an environment level to enable different credentials to be used when deploying to different environments (e.g. Production/Development)._

### Create a change

Create a new change for the current `origin/master` branch of your project and run the `default` action:

```bash
opschain change create --project-code ansible --environment-code ansbl --git-remote-name origin --git-rev master --action default --confirm
```

_Note: the first time you run a change from this project it may take a long time as it constructs the Runner image (with Terraform, Ansible and the AWS CLI)._

The [steps](../reference/concepts/concepts.md#step) that comprise the change will be shown as well as their status.

### Verify change deployment

The newly created `opschain-ansible` [key pair](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#KeyPairs:) and [security group](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#SecurityGroups:sort=group-name) can be viewed from your AWS Console.

Use the [AWS instances](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#Instances:) page to determine the "Public IPv4 address" assigned to your `opschain-ansible` instance. Copy this IP address into the address bar of your browser to see the OpsChain AWS Ansible Demo welcome page.

### Update the welcome page

Create a new change for the current `origin/master` branch of your project and run the `nginx_host:deploy_index` action:

```bash
opschain change create --project-code ansible --environment-code ansbl --git-remote-name origin --git-rev master --action nginx_host:deploy_index --confirm
```

Refresh the OpsChain AWS Ansible Demo welcome page page and note the last changed date has been updated to reflect the new deployment.

#### Destroy the AWS resources

The EC2 instance, security group and key pair can be removed by running:

```bash
opschain change create --project-code ansible --environment-code ansbl --git-remote-name origin --git-rev master --action destroy --confirm
```

_Note: the AWS Console pages described in the [verify change deployment](#verify-change-deployment) steps above can be used to confirm the aws resources have been removed/terminated._

## Notes on the Ansible example

### File storage

The `aws_keys:create` and `:save_known_hosts` actions in the main [actions.rb](https://github.com/LimePoint/opschain-examples-ansible/blob/master/actions.rb) use the OpsChain `store_file!` helper to save the generated SSH keys and known_hosts file changes in the environment properties. This allows these files to be available for all subsequent steps.

### MintPress transport

The [nginx_host resource](https://github.com/LimePoint/opschain-examples-ansible/blob/master/lib/nginx_host/resource.rb) uses the `erb_file` feature of a [MintPress](https://www.limepoint.com/mintpress) Transport to dynamically construct and overwrite the OpsChain Welcome Page (index.html) on the EC2 host. This is just one example of the features you can extend your resource types with when incorporating MintPress controllers.

### Repository Dockerfile

The [`Dockerfile`](https://github.com/LimePoint/opschain-examples-ansible/blob/master/.opschain/Dockerfile) in `.opschain` builds a custom OpsChain step runner image that includes the:

- AWS CLI
- Ansible yum package
- Terraform binary

### External packages

The example makes use of the [AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).

## What to do next

### Try a more advanced example

The [Confluent example](running_a_complex_change.md) demonstrates how to use OpsChain to build and deploy a multi-node [Confluent](https://www.confluent.io) environment.

### Create your own project

Try creating a new project using the steps above and instead of adding a remote, author your own commits. See the [reference documentation](../reference/README.md) and [developing your own resources](/docs/getting_started/developer.md#developing-resources) guide for more information.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
