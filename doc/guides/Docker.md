# Docker namespace

**Usage example**: try to pull image from 3 tags in order (from more specific or
recent to the less one)

```bash
# try to pull image from 3 tags in order (from more specific or recent to the less one)
args=(
  'id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools:d93e03d5ab9e127647f575855f605bd189ca8a56'
  'id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools:branchName'
  'id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools:master'
)
digestPulled="$(Docker::pullImage "${args[@]}")"

# build the image using eventual image pulled as cache
# image will be tagged bash-tools:latest upon successful build
args=(
  "." ".docker/Dockerfile" "bash-tools"
  # it's important to not double quote following instruction
  $(Docker::getBuildCacheFromArg ${digestPulled})
  # you can add any additional docker build arg as needed
  --build-arg USER_ID="$(id -u)"
  --build-arg GROUP_ID="$(id -g)"
)
Docker::buildImage "${args[@]}"

# tag the image with a remote tag
args=(
  "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools"
  "bash-tools:latest"
  # tags list
  "branchName" "d93e03d5ab9e127647f575855f605bd189ca8a56"
)
Docker::tagImage "${args[@]}"

# finally push the image
args=(
  "id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools"
  "bash-tools:latest"
  # tags list
  "branchName" "d93e03d5ab9e127647f575855f605bd189ca8a56"
)
Docker::pushImage "${args[@]}"
```
