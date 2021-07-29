# Changelog

## [2021-03-09]

### Added
- Automatically expose [Controller Actions and Properties](docs/reference/actions.md#controller-actions-and-properties) in resource types and resources.
- [upgrading.md](docs/upgrading.md) documentation.

### Changed
- Upgraded OpsChain Log Aggregator Image Fluentd from version 1.11 to 1.12.1
- Upgraded OpsChain LDAP Image OpenLDAP from version 2.4.50 to 2.4.57
- Upgraded OpsChain DB Image Postgres from 13.1 to 13.2
- Upgraded OpsChain Runner Image Terraform from 0.12.29 to 0.14.7.
  _Please note, project Git repositories will need to be updated:_
  - [terraform 0.12 -> 0.13](https://www.terraform.io/upgrade-guides/0-13.html) - will assist in creating a `versions.tf` in your project git repository(s).
  - [terraform 0.13 -> 0.14](https://www.terraform.io/upgrade-guides/0-14.html) - provides information on the new `.terraform.lock.hcl` lock file.
