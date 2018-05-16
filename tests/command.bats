#!/usr/bin/env bats

load "$BATS_PATH/load.bash"

# export AWS_STUB_DEBUG=/dev/tty
# export SSH_ADD_STUB_DEBUG=/dev/tty
# export SSH_AGENT_STUB_DEBUG=/dev/tty
# export GIT_STUB_DEBUG=/dev/tty

@test "Read parameter from ssm" {

    export AWS_DEFAULT_REGION="ap-southeast-2"
    export BUILDKITE_PIPELINE_SLUG="example-pipeline"
    export BUILDKITE_COMMAND='command1 "a string"'
    export BUILDKITE_PLUGIN_SSM="SSM"
    export BUILDKITE_PLUGIN_SSM_SSMKEY="MySecretKey"

    export BUILDKITE_PLUGIN_SSM_ASSUME_ROLE_ARN="arn:aws:iam::123456789012:role/xaccounts3access"
    export BUILDKITE_PLUGIN_SSM_ASSUME_ROLE_SESSION_NAME="s3-access-example"
    export BUILDKITE_PLUGIN_SSM_ASSUME_ROLE_DURATION="60"
    export BUILDKITE_PLUGIN_SSM_ASSUME_ROLE_EXTERNAL_ID="123456789012"
#    "sts assume-role --role-arn arn:aws:iam::123456789012:role/xaccounts3access --role-session-name s3-access-example --duration-seconds 60 --external-id : exit 1"

    stub awssts \
    "sts assume-role --role-arn arn:aws:iam::123456789012:role/xaccounts3access : exit 1"

    stub aws \
    "ssm get-parameters --region ap-southeast-2 --names MySecretKey1 --with-decryption --query Parameters[0].Value : exit 1" \
    "ssm get-parameters --region ap-southeast-2 --names MySecretKey2 --with-decryption --query Parameters[0].Value : exit 1"

    run bash -c "$PWD/hooks/command"

    assert_success

#    unstub aws
#    unstub awssts
}

