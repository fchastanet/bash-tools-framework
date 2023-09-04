%
declare versionNumber="1.0"
declare commandFunctionName="buildPushDockerImagesCommand"
declare help="pull, build and push docker image

- pull previous docker image from docker hub if
  exists
- build new image using previous image as cache
- tag built image
- push it to docker registry

additional docker build options can be passed via
DOCKER_BUILD_OPTIONS env variable

INTERNAL
"

%
.INCLUDE "$(dynamicTemplateDir _binaries/options.base.tpl)"
%
# shellcheck source=/dev/null
source <(
Options::generateArg \
  --variable-name "argVendor" \
  --name "vendor" \
  --help "vendor image to use (alpine or ubuntu)" \
  --authorized-values "alpine|ubuntu" \
  --function-name argVendorFunction

Options::generateArg \
  --variable-name "argBashTarVersion" \
  --name "bash_tar_version" \
  --help "version of bash to use" \
  --authorized-values "4.4|5.0|5.1|5.2" \
  --function-name argBashTarVersionFunction

Options::generateArg \
  --variable-name "argBashBaseImage" \
  --name "bash_base_image" \
  --help "bash bash image to use (eg: ubuntu:20.04, amd64/bash:4.4-alpine3.18)" \
  --function-name argBashBaseImageFunction

Options::generateArg \
  --variable-name "argBranchName" \
  --min 0 \
  --name "branch_name" \
  --help "branch name being built, will help to create docker image tag name" \
  --function-name argBranchNameFunction

Options::generateOption \
  --help "if provided, push the image to the registry" \
  --alt "--push" \
  --variable-name "optionPush" \
  --function-name optionPushFunction
)
options+=(
  argVendorFunction
  argBashTarVersionFunction
  argBashBaseImageFunction
  argBranchNameFunction
  optionPushFunction
)
Options::generateCommand "${options[@]}"
%
