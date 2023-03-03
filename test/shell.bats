#!/usr/bin/env bats

load test_helper

@test "shell integration disabled" {
  run zigenv shell
  assert_failure
  assert_output "zigenv: shell integration not enabled. Run \`zigenv init' for instructions."
}

@test "shell integration enabled" {
  eval "$(zigenv init -)"
  run zigenv shell
  assert_success
  assert_output "zigenv: no shell-specific version configured"
}

@test "no shell version" {
  mkdir -p "${ZIGENV_TEST_DIR}/myproject"
  cd "${ZIGENV_TEST_DIR}/myproject"
  echo "1.2.3" > .zig-version
  ZIGENV_VERSION="" run zigenv-sh-shell
  assert_failure
  assert_output "zigenv: no shell-specific version configured"
}

@test "shell version" {
  ZIGENV_SHELL=bash ZIGENV_VERSION="1.2.3" run zigenv-sh-shell
  assert_success
  assert_output 'echo "$ZIGENV_VERSION"'
}

@test "shell version (fish)" {
  ZIGENV_SHELL=fish ZIGENV_VERSION="1.2.3" run zigenv-sh-shell
  assert_success
  assert_output 'echo "$ZIGENV_VERSION"'
}

@test "shell revert" {
  ZIGENV_SHELL=bash run zigenv-sh-shell -
  assert_success
  assert_line -n 0 'if [ -n "${ZIGENV_VERSION_OLD+x}" ]; then'
}

@test "shell revert (fish)" {
  ZIGENV_SHELL=fish run zigenv-sh-shell -
  assert_success
  assert_line -n 0 'if set -q ZIGENV_VERSION_OLD'
}

@test "shell unset" {
  ZIGENV_SHELL=bash run zigenv-sh-shell --unset
  assert_success
  assert_output - <<OUT
ZIGENV_VERSION_OLD="\$ZIGENV_VERSION"
unset ZIGENV_VERSION
OUT
}

@test "shell unset (fish)" {
  ZIGENV_SHELL=fish run zigenv-sh-shell --unset
  assert_success
  assert_output - <<OUT
set -gu ZIGENV_VERSION_OLD "\$ZIGENV_VERSION"
set -e ZIGENV_VERSION
OUT
}

@test "shell change invalid version" {
  run zigenv-sh-shell 1.2.3
  assert_failure
  assert_output - <<SH
zigenv: version \`1.2.3' not installed
false
SH
}

@test "shell change version" {
  mkdir -p "${ZIGENV_ROOT}/versions/1.2.3"
  ZIGENV_SHELL=bash run zigenv-sh-shell 1.2.3
  assert_success
  assert_output - <<OUT
ZIGENV_VERSION_OLD="\$ZIGENV_VERSION"
export ZIGENV_VERSION="1.2.3"
OUT
}

@test "shell change version (fish)" {
  mkdir -p "${ZIGENV_ROOT}/versions/1.2.3"
  ZIGENV_SHELL=fish run zigenv-sh-shell 1.2.3
  assert_success
  assert_output - <<OUT
set -gu ZIGENV_VERSION_OLD "\$ZIGENV_VERSION"
set -gx ZIGENV_VERSION "1.2.3"
OUT
}
