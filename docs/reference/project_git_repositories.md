# OpsChain project Git repositories guide

A project Git repository is where you store the actions and related configuration to apply to the project's environments. OpsChain will read all action and resource definitions from the `actions.rb` file in the repository root directory. See the [actions reference guide](actions.md) and [developing your own resources](../developing_resources.md) guide for further information about the contents of the `actions.rb` file.

## Minimum Requirements

Each project Git repository must include a `Gemfile` and an `actions.rb` in the root directory.

- The `Gemfile` must include the `opschain-core` gem.

  ```ruby
  gem 'opschain-core'
  ```

- The `actions.rb` must include a `require` for the `opschain-core` gem.

  ```ruby
  require 'opschain-core'
  ```

## Adding a project Git repository as a remote

### Create a GitHub personal access token

If you choose to use your GitHub username and password when connecting the example repository, you will see warnings displayed whenever OpsChain accesses the repository. Alternatively, follow the GitHub guide to create a [GitHub personal access token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token).

### Set the project Git remote

Add the project Git repository as a [remote](https://git-scm.com/book/en/v2/Git-Basics-Working-with-Remotes):

```bash
# Note: to avoid potentially storing the repository credentials in the shell history the `--url` argument can be omitted and filled in when prompted
$ opschain project set-git-remote --project-code <project code> --name origin --url "https://{username}:{password / personal access token}@github.com/LimePoint/{repository name}.git"
```

_Note: If your password/token contains special characters, they must be [URL encoded](https://www.w3schools.com/tags/ref_urlencode.asp) in order to use them in the URL parameter._

### Project Git repository remote credentials

To be used by OpsChain, the remote must be either:

- An unauthenticated Git remote
- A http(s) authenticated Git remote where the username and password are embedded in the remote URL. For example `https://username:password@github.com/LimePoint/opschain-examples-confluent.git`

OpsChain does not support any other authentication mechanisms for Git remotes.

_Using SSH keys for authentication is not supported however some users have reported success with this [unsupported workaround](../troubleshooting.md#git-remotes-with-ssh-authentication)._

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../../LICENCE)
