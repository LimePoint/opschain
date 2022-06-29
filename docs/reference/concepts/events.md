# OpsChain events

This guide gives an overview of event tracking with OpsChain.

After following this guide you should know:

- what events are created by OpsChain automatically
- how to query events via the API
- how to create custom events using the API

_Note: All the examples in this guide assume the OpsChain API server is running on your local machine. Replace `localhost` with your OpsChain server name if connecting to a remote OpsChain server._

## Overview

OpsChain tracks all interactions with the OpsChain API for auditing and reporting purposes. In future versions OpsChain will track more events, please [let us know](mailto:opschain-support@limepoint.com) if there are particular events you would like tracked.

_Note: OpsChain does not track API requests to the `/events` API itself._

The data provided within the `attributes` section of the event API response varies depending on the type of event.

All automatically created API events start with the `api:` prefix and are then followed by the API controller, and then the API method. The `index` method is analogous to `list`.

A full list of API events is available [below](#list-of-events).

## Viewing events

The OpsChain `/events` endpoint can be queried to see events in the OpsChain system.

```bash
curl -u "{{username}}:{{password}}" http://localhost:3000/events
```

The response is a [JSON:API](https://jsonapi.org/) payload containing a list of the most recent events. The response will include the relevant events from oldest to newest in the response `data` array, i.e. `data[0]` will be the oldest event in the result set.

### Example project index event

Below is an example of a project index event returned by the `/events` endpoint.

```json
{
  "id": "43404b06-e265-4d4e-a387-4fc83320a778",
  "type": "event",
  "attributes": {
    "username": "opschain",
    "system": true,
    "type": "api:projects:index",
    "created_at": "2021-01-01T01:00:00.000000Z"
  },
  "relationships": {},
  "links": {
    "self": "/events/43404b06-e265-4d4e-a387-4fc83320a778"
  }
}
```

### Filtering events

The query to the `/events` endpoint can be filtered by providing the relevant query parameters.

For example, the following query will return up to 100 events that were created after 2021-01-01.

_Note: By default, the response is limited to only 10 events, and there is a hard limit of 1000 events. The response status code will be 206 Partial Content when the response has been truncated by the limit._

```bash
curl --globoff --user "{{username}}:{{password}}" 'http://localhost:3000/events?filter[created_at_gt]=2021-01-01T01:00:00.000000Z&limit=100'
```

_Note: The `--globoff` argument is required when using the filtering queries using `curl`._

Some sample queries are shown below. The full list of supported query suffixes can be seen [here](https://github.com/activerecord-hackery/ransack/blob/7fc31667b46845e66b5075fc03c536e7b15a5e46/lib/ransack/locale/en.yml#L16).

The format of the query parameter is `filter[{{field}}_{{filter_predicate}}]={{value}}`.

Multiple filters are combined using a "logical and". To use a "logical or" add `filter[m]=or` to the query, e.g. `?filter[first_name_eq]=fred&filter[full_name_start]=fred&filter[m]=or` would filter for custom events with a first name of `fred`, or full name starting with `fred`.

The `request_body` and `url_params` nested data can be filtered using the respective name as a prefix to the filter - there is an example in the table below.

#### Query examples

| Example                                                                                 | Description                                                                               |
| :-------------------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------- |
| `?filter[created_at_lt]=2021-01-01T01:00:00.000000Z`                                    | Events older than 2021-01-01 - this can be useful for paginating back through old events. |
| `?filter[type_eq]=api:projects:create`                                                  | API requests to create a project - the full list of types is [below](#list-of-events).    |
| `?filter[request_body_action_eq]=provision&filter[type_eq]=api:changes:create`          | API requests to create a change with the `provision` action.                              |
| `?filter[url_params_project_code_eq]=demo&[type_eq]=api:git_remotes:update`             | API requests to update the `demo` project Git remote.                                     |
| `?filter[type_in][]=api:properties_versions:show&filter[type_in][]=api:properties:show` | API requests to show properties, including older versions.                                |
| `?filter[environment_code_eq]=prod`                                                     | API requests for the `prod` environment.                                                  |
| `?filter[system_eq]=false&filter[name_start]=some`                                      | Custom events with a custom `name` field beginning with `some`.                           |

### List of events

The following is the list of API events that are currently supported, these values will be present in the `type` field for an event:

- `api:automated_change_rules:create`
- `api:automated_change_rules:destroy`
- `api:automated_change_rules:index`
- `api:automated_change_rules:show`
- `api:changes:create`
- `api:changes:destroy`
- `api:changes:index`
- `api:changes:show`
- `api:environments:create`
- `api:environments:update`
- `api:environments:destroy`
- `api:environments:index`
- `api:environments:show`
- `api:git_remotes:create`
- `api:git_remotes:index`
- `api:git_remotes:show`
- `api:git_remotes:update`
- `api:git_remotes:destroy`
- `api:log_lines:index`
- `api:projects:create`
- `api:projects:update`
- `api:projects:destroy`
- `api:projects:index`
- `api:projects:show`
- `api:properties:show`
- `api:properties:update`
- `api:properties_versions:index`
- `api:properties_versions:show`
- `api:steps:continue`
- `api:steps:show`

Custom (i.e. user created) events can have any `type` as it is specified when the event is created.

### Examples

Below are some examples of querying the `/events` API.

_Note: the examples require the `jq` and `curl` utilities, and have been tested with Zsh and Bash 4._

#### Waiting for an event to occur

The following is an example of watching the events API waiting for an event to occur.

```bash
user='{{username}}:{{password}}'
since="$(date --iso-8601=ns)"
event='api:changes:create'

while true; do
  response="$(curl -s -G --user "${user}" http://localhost:3000/events --data-urlencode "filter[created_at_gt]=${since}")"
  matches="$(jq --arg event "${event}" '.data | map(select(.attributes.type == $event))' <<<"${response}")"
  if jq -e 'length > 0' <<<"${matches}" >/dev/null; then
    echo "${matches}"
    break
  fi
  since="$(jq -r --arg since "${since}" '.data[-1].attributes.created_at // $since' <<<"${response}")"
  sleep 1
done
```

#### Paginating through events

The following is an example of paginating backwards through the events API. It will output the newest event to the oldest.

```bash
user='{{username}}:{{password}}'

while true; do
  response="$(curl -s -G --user "${user}" http://localhost:3000/events --data-urlencode "filter[created_at_lt]=${before}")"
  before="$(jq -r '.data[0].attributes.created_at // empty' <<<"${response}")"
  if [[ -z "${before}" ]]; then
    break
  fi
  jq '.data | reverse[]' <<<"${response}"
done
```

## Creating custom events

Events can be created in the OpsChain events framework by sending a `POST` request to the `/events` endpoint.

The request needs to be a valid [JSON:API](https://jsonapi.org/) request. E.g.

```bash
curl --fail --user {{username}}:{{password}} http://localhost:3000/events -H 'content-type: application/vnd.api+json' -d '{ "data": { "type": "Event", "attributes": { "type": "custom", "some": "value", "nesting": { "also": "works" } } } }'
curl --fail --user {{username}}:{{password}} http://localhost:3000/events -H 'content-type: application/vnd.api+json' -d @event-file.json
```

OpsChain responds with a 201 status code and no response body when the event is created successfully.

### System created events

Events created internally by OpsChain can be identified by the `system` property. If `system` is `true` then the event was created by OpsChain, if it is `false` then the event was created by a user using the `/events` endpoint - the `username` field identifies the user that created the request.

## Removing events

Older OpsChain events can be removed, see the [OpsChain data retention](/docs/operations/maintenance/data_retention.md) guide for more details.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
