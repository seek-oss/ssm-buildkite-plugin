# ssm-buildkite-plugin - AWS Systems Manager Parameter Store Buildkite Plugin

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) to expose parameters to build steps via Amazon Systems Manager Parameter Store.

Parameters retrieved from the parameter store are exported as environment variables.

Supported types:
- String
- SecureString

## Example

Uploading Parameter to AWS SSM
```bash
aws ssm put-parameter --name "MySecret" --value "ThisIsMySecretValue" --type String
```

The following pipeline step will assume an aws role and then retrieve and decrypt the ssm parameter. The parameter will be exported as an environment variable.
```yml
steps:
- label: ":arrow_double_up::load: Load SSM"
  command: "env | grep MySecret"
  plugins:
    - seek-oss/ssm#v0.1.0:
        assume-role-arn: "arn:aws:iam::123456789012:role/RoleToAssume-1234567890"
        ssmkey: "MySecret"
```

The resulting environment variable will be named 'MySecret'
```
Running commands
$ env | grep MySecret
BUILDKITE_PLUGINS=[{"github.com/seek-oss/ssm-buildkite-plugin#v0.1.0":{"ssmkey":"MySecret","assume-role-arn":"arn:aws:iam::123456789012:role/RoleToAssume-1234567890"}}]
BUILDKITE_SCRIPT_PATH=env | grep MySecret
BUILDBOX_COMMAND=env | grep MySecret
BUILDKITE_COMMAND=env | grep MySecret
BUILDBOX_SCRIPT_PATH=env | grep MySecret
MySecret=ThisIsMySecretValue
```

## Installation

This plugin needs to be installed directly in the agent so that parameters can be downloaded before jobs attempt checking out your repository.
We are going to assume that buildkite has been installed at `/buildkite`, but this will vary depending on your operating system.
Change the instructions accordingly.

```
# clone to a path your buildkite-agent can access
git clone https://github.com/seek-oss/ssm-buildkite-plugin.git /buildkite/ssm
```

Before running commands the agent will run the pre-command hook (see https://buildkite.com/docs/agent/v3/hooks#available-hooks):

### `${BUILDKITE_ROOT}/hooks/pre-command`

```bash
if [[ "${SSM_PLUGIN_ENABLED:-1}" == "1" ]] ; then
  source /buildkite/ssm/hooks/pre-command
fi
```

## Usage

When run via the agent pre-command, if specified a role will be assumed, the SSM parameter will be retrieved and decrypted.
The value is then exported as environment variables.

## License

MIT (see [LICENSE](LICENSE))

## Credit
Credit to [Buildkite plugin](https://github.com/cultureamp/aws-assume-role-buildkite-plugin) for the assume IAM Role.
