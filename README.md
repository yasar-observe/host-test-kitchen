# Test Kitchen with Docker and CloudFormation

This project uses Test Kitchen with Docker to validate our infrastructure and cloudformation. It includes a Makefile for easy command handling and a Dockerfile to create a standardized testing environment.

## Environment Variables

These environment variables are used for running the tests:

- `OBSERVE_CUSTOMER`: The Observe customer
- `OBSERVE_TOKEN`: The Observe token
- `OBSERVE_DOMAIN`: The Observe environment domain (default: observe-eng.com)
- `AWS_ACCESS_KEY_ID`: Your AWS access key ID
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key
- `AWS_SESSION_TOKEN`: Your AWS session token (if required)
- `AWS_REGION`: Your preferred AWS region (default: us-east-1)
- `PROVIDER`: `terraform` or `cloudformation` (default: cloudformation)

If you want to persist your environment configuration a `env.template` file is available

```
cp env.template .env
vi .env # edit the values
source .env
```

We're ignoring `.env*` so feel free make as many as required ie `.env-cloudformation` or `.env-accountnumber` etc

## Docker

### Prerequisites

1. AWS Access ( `aws sts get-caller-identity` is your friend )
2. A valid observe customer / token / domain
3. Docker installed

### Testing

1. Run the tests within a docker container by running `make docker/test`.
2. To clean up the resources created during the test, run `make docker/test/clean`
3. To clean up the resources including the docker image / container run `make docker/clean`

## Manual

### Prerequisites

1. AWS Access ( `aws sts get-caller-identity` is your friend )
2. A valid observe customer / token / domain
3. Ensure the dependencies within the `./validate_deps.sh` script are installed by running `./validate_deps.sh`.
4. Install the gems listed within the Gemfile via `bundler install`.

### Testing

1. Run `make test` to validate dependencies, create the kitchen environment and run the verifier.
2. To clean up the resources created during the test, run `make test/clean`.

## Test Kitchen 101
Refer to the test kitchen (documentation)[https://kitchen.ci/docs/getting-started/introduction/] but bellow is a brief explanation of some common commands.

Provision the infrastructure
```
# make test/create
kitchen create
```

Test the infrastructure agains the spec
```
# make test/verify
kitchen verify

# the rspec equivalent
rspec -c -f documentation --default-path '/workdir'  -P 'test/integration/base/verify/collection_spec.rb'
```

Teardown the infrastructure
```
# make test/clean
kitchen destroy
```

