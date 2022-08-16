# Archiving projects & environments

To ensure information about historical changes remains available for audit purposes, OpsChain provides the ability to archive unwanted projects and environments. After following this guide you should know:

- how to archive projects and environments
- the effect archiving has on a project/environment within OpsChain
- how to unarchive projects and environments

## Archiving via the CLI

The OpsChain CLI provides the `archive` command, that can be applied to a `project` or `environment`:

```bash
opschain project archive
```

_Note: Projects and environments cannot be archived if they contain a queued or running change. Please ensure all relevant changes are complete (or cancelled) prior to executing the command._

## Affect on OpsChain

Archiving an environment:

- disables its automated change rules
- prevents new changes (and change rules) being created in it

Archiving a project has the effect of archiving all its environments.

### CLI output

Archiving a project or environment will mean the resource no longer appears in:

1. the interactive list presented to users when selecting parameter values.
2. the output of the relevant OpsChain `list` output. e.g. an archived environment will not appear in the `opschain environment list` output. The optional `--include-archived` (`-a`) parameter can be supplied to include archived resources in the output. e.g.

    ```bash
    opschain environment list --project-code demo --include-archived
    ```

If an archived environment is specified when running the OpsChain `change list` or `automated-change list` command the relevant results will continue to be displayed. The `Next Run At` column in the automated changes list will be empty to denote their disabled status._

### API responses

By default, archived resources are included in the results returned from the API endpoints. This ensures the full audit history of all actions performed in the project/environment remains available for enquiry. The `projects` and `environments` endpoints include an `archived` attribute for each record that can be used to identify those that are archived.

#### Result filtering

If required, the API endpoints allow you to use result filtering (described in more detail in [the events guide](events.md#filtering-events)) to return only active projects or environments. To do this, append the filter `filter[archived_eq]=false` to your API request. e.g.

```text
http://localhost:3000/projects?filter[archived_eq]=false`
```

### Changes and automated change rules

Once archived, attempts to create a change or automated change rule in an archived environment will be rejected with an error reflecting the environment's archived status.

Automated change rules that exist for an archived environment will be disabled and will not run whilst the environment remains archived.

## Unarchiving projects and environments

Archiving a resource is intended as a one way process and the CLI does not provide an option to unarchive them. In the event that you need to unarchive a project or environment, you will need to interact directly with the API server. The following example patch request will unarchive the `dev` environment in the `demo` project:

```bash
curl -u opschain:password -X PATCH http://localhost:3000/projects/demo/environments/dev -H "Accept: application/vnd.api+json" -H "Content-Type: application/vnd.api+json" --data-binary @- <<DATA
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

- `opschain:password` with your username and password
- `localhost:3000` with the OpsChain host and port
- `projects/demo/environments/dev` with the appropriate path for the archived resource. e.g.
  - `projects/<project code>` to unarchive a project
  - `projects/<project code>/environments/<environment code>` to unarchive an environment
  - `projects/<project code>/git_remotes/<git remote id>` to unarchive a git remote

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
