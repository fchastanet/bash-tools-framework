%
declare versionNumber="1.0"
declare commandFunctionName="buildPushDockerImageCommand"
# shellcheck disable=SC2016
declare help='pull, build and push docker image

- pull previous docker image from docker hub if
  exists
- build new image using previous image as cache
- tag built image
- push it to docker registry

additional docker build options can be passed
  via ${__HELP_OPTION_COLOR}DOCKER_BUILD_OPTIONS${__HELP_NORMAL} env variable

INTERNAL
'

%
.INCLUDE "$(dynamicTemplateDir _binaries/options/options.base.tpl)"
.INCLUDE "$(dynamicTemplateDir _binaries/options/options.bashFrameworkDockerImage.tpl)"
%
# shellcheck source=/dev/null
source <(
  Options::generateOption \
    --help "if provided, push the image to the registry" \
    --alt "--push" \
    --variable-name "optionPush" \
    --function-name optionPushFunction
)
options+=(
  optionPushFunction
)
Options::generateCommand "${options[@]}"
%
declare copyrightBeginYear="2023"
