#!/usr/bin/env bash

find . -name "*.sh" -print0 | xargs -0 shellcheck -x
