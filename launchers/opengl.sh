#!/bin/bash

# YOUR CODE BELOW THIS LINE
# ----------------------------------------------------------------------------

set -eu

# constants
APP=glxgears

# run X
launcher-xorg

# run with OpenGL
vglrun -- "${APP}"

# ----------------------------------------------------------------------------
# YOUR CODE ABOVE THIS LINE
