#!/bin/bash

# YOUR CODE BELOW THIS LINE
# ----------------------------------------------------------------------------

set -eu

# constants
APP=glxgears

# run X
launcher-xorg

# run with OpenGL
${APP}

vglrun -- "${APP}"


#glxinfo

# ----------------------------------------------------------------------------
# YOUR CODE ABOVE THIS LINE
