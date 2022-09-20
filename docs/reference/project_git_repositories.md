# OpsChain project Git repositories guide

A project Git repository is where you store the actions and related configuration to apply to the project's environments. OpsChain will read all action and resource definitions from the `actions.rb` file in the repository root directory. See the [actions reference guide](concepts/actions.md) and [developing your own resources](/docs/getting_started/developer.md#developing-resources) guide for further information about the contents of the `actions.rb` file.

## Minimum Requirements

Each project Git repository must include a `Gemfile` and an `actions.rb` in the root directory.

- The `Gemfile` must include the `opschain-core` Gem.

  ```ruby
  gem 'opschain-core', require: 'opschain'
  ```

- The `actions.rb` must include a `require` for the `opschain` library.

  ```ruby
  require 'opschain'
  # optionally, to avoid requiring each dependency manually, the following can be used instead:
  Bundler.require
  ```

## Adding a project Git repository as a remote

### Create a GitHub personal access token

If you choose to use your GitHub username and password when connecting the example repository, you will see warnings displayed whenever OpsChain accesses the repository. Alternatively, follow the GitHub guide to create a [GitHub personal access token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token).

### Set the project Git remote

Add the project Git repository as a [remote](https://git-scm.com/book/en/v2/Git-Basics-Working-with-Remotes):

```bash
# Note: to avoid potentially storing the repository credentials in the shell history the `--user` and `--password` arguments can be omitted and filled in when prompted
# Example 1: Using password authentication:
$ opschain project add-git-remote --project-code <project code> --name origin --user '{username}' --password '{password / personal access token}' --url 'https://github.com/LimePoint/{repository name}.git'
# Example 2: Using SSH authentication: using a key
$ opschain project add-git-remote --project-code <project code> --name origin --ssh-key-file ./path/to/private/key --url 'git@github.com:LimePoint/{repository name}.git'
# Example 3: Using SSH authentication: using credentials
$ opschain project add-git-remote --project-code <project code> --name origin --user '{ssh username}' --password '{ssh password}' --url 'ssh://repo.example.com/{repository name}.git' --ssh-key-file ''
# Example 4: Using SSH authentication: using a key with a passphrase
$ opschain project add-git-remote --project-code <project code> --name origin --ssh-key-file ./path/to/private/key --username git --password '{ssh key passphrase}' --url 'ssh://github.com:LimePoint/{repository name}.git'
```

## SSH Git remotes

OpsChain supports using SSH for project Git remotes using SSH keys or passwords (including keys that require a passphrase) - as shown in the [examples above](#set-the-project-git-remote).

OpsChain includes a bundled SSH `known_hosts` file which includes SSH keys for a number of common source code hosting platforms, including:

- Bitbucket
- GitHub
- GitLab

The configured SSH keys can be seen by running the following command:

```bash
kubectl -n opschain get ConfigMap opschain-ssh-known-hosts -o jsonpath='{.data.known_hosts}'
```

The Git remote is tested during the `add-git-remote` request, and if your SSH endpoint is not trusted by the bundled `known_hosts` list then the remote will not be added.

### Customising the SSH `known_hosts` file

The bundled SSH `known_hosts` file can be customised by creating a new config map, configuring OpsChain to use it, and applying the updated config.

The following steps assume you are using the default `OPSCHAIN_KUBERNETES_NAMESPACE` (`opschain`). Modify the commands if your namespace is different.

The bundled config map can be used as a template to help create the custom `known_hosts` config map:

```bash
# these commands assume you are using the default `OPSCHAIN_KUBERNETES_NAMESPACE` value of `opschain`
kubectl -n opschain get ConfigMap opschain-ssh-known-hosts -o yaml > custom-opschain-ssh-known-hosts.yaml
```

Then edit the exported resource, ensure you update the `metadata.name` field to a different config map name, and then update the file contents under the known_hosts key. Once the resource definition has been updated, use `kubectl` to create the custom config map:

```bash
kubectl -n opschain apply -f custom-opschain-ssh-known-hosts.yaml
```

Next update your server configuration's `.env` file to use the custom config map by updating the `OPSCHAIN_SSH_KNOWN_HOSTS_CONFIG_MAP` configuration to use the custom config map name that was used when modifying the YAML file above. Once this has been done, rerun the OpsChain configuration, and apply the update:

```bash
opschain server configure
opschain server deploy
```

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
