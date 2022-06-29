# Git remotes

This guide takes you through the operations required for managing remote Git repositories for your OpsChain projects.

## Creating a new Git remote

Creating a new Git remote can be done via the CLI.

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

## Listing all Git remotes on a project

You can view all the active Git remotes on a project via the CLI.

```bash
opschain project list-git-remotes --project-code <project code>
```

## Updating a Git remote

OpsChain only supports archiving or unarchiving a Git remote via its update endpoint.

### Archiving

Archiving an existing Git remote can be done via the CLI.

```bash
opschain project archive-git-remote --project-code <project code> --name <remote name>
```

### Getting the Git remote ID

The following API only commands will require you to supply the Git remote ID in the URL. To identify the required id, query the Git remotes endpoint for the project:

```bash
curl -u opschain:password http://localhost:3000/projects/demo/git_remotes | jq
```

Note: You will need to edit the example to replace:

- `opschain:password` with your username and password
- `localhost:3000` with the OpsChain host and port
- `demo` with your target project code

### Unarchiving a Git remote

Similar to [unarchiving projects and environments](archiving.md#unarchiving-projects-and-environments), archiving a Git remote is intended as a one way process. If you need to unarchive a Git remote, you will need to interact directly with the API server. OpsChain will only allow unarchiving if the Git remote, with its saved url and credentials, is still accessible.

The following command will unarchive a Git remote with ID `cfebaf57-42c3-4df6-bf1d-4ae6f9094ec1` from the `demo` project.

```bash
curl -u opschain:password -X PATCH http://localhost:3000/projects/demo/git_remotes/cfebaf57-42c3-4df6-bf1d-4ae6f9094ec1 -H "Accept: application/vnd.api+json" -H "Content-Type: application/vnd.api+json" --data-binary @- <<DATA
{
  "data": {
    "attributes": {
      "archived": false
    }
  }
}
DATA
```

Note: You will need to edit the example to replace:

- `cfebaf57-42c3-4df6-bf1d-4ae6f9094ec1` with the Git remote ID
- `opschain:password` with your username and password
- `localhost:3000` with the OpsChain host and port
- `demo` with your target project code

## Deleting a Git remote

You can use the API server's Git remote delete endpoint in the event you wish to delete a Git remote.

The following command will delete a Git remote with ID `cfebaf57-42c3-4df6-bf1d-4ae6f9094ec1` from the `demo` project.

```bash
curl -u opschain:password -X DELETE http://localhost:3000/projects/demo/git_remotes/cfebaf57-42c3-4df6-bf1d-4ae6f9094ec1 -H "Accept: application/vnd.api+json" -H "Content-Type: application/vnd.api+json"
```

- `cfebaf57-42c3-4df6-bf1d-4ae6f9094ec1` with the Git remote ID (must be in an archived state)
- `opschain:password` with your username and password
- `localhost:3000` with the OpsChain host and port
- `demo` with your target project code

### Deleting unused Git remotes

If the Git remote has not been used by a change (or an automated change), OpsChain can safely delete the Git remote.

### Deleting used Git remotes

In order to maintain OpsChain's audit trail, if a Git remote has been used by a change, OpsChain will not delete the Git remote. Instead, the Git remote's credentials (user, password, ssh_key_data) will be removed from the database but the record will remain.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
