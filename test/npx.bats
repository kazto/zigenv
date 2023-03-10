#!/usr/bin/env bats

load test_helper

create_executable() {
  name="${1?}"
  shift 1
  bin="${ZIGENV_ROOT}/versions/${ZIGENV_VERSION}/bin"
  mkdir -p "$bin"
  { if [ $# -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed -Ee '1s/^ +//' > "${bin}/$name"
  chmod +x "${bin}/$name"
}

@test "shims are removed from PATH when executing npx" {
  # emulate npx to look for existing bin
  ZIGENV_VERSION=8.0 create_executable "npx" <<SH
#!$BASH
exec which -a \$1
SH

  # bin available in other node version
  ZIGENV_VERSION=6.0 create_executable "some_dummy_exe_that_wont_conflict" "#!/bin/sh"

  zigenv-rehash

  ZIGENV_VERSION=8.0 run zigenv-exec npx some_dummy_exe_that_wont_conflict

  refute_output # fake npx just does 'which' and shouldn't find the dummy exe
}
