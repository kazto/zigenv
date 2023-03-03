#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "${ZIGENV_TEST_DIR}/myproject"
  cd "${ZIGENV_TEST_DIR}/myproject"
}

@test "no version" {
  assert [ ! -e "${PWD}/.zig-version" ]
  run zigenv-local
  assert_failure
  assert_output "zigenv: no local version configured for this directory"
}

@test "local version" {
  echo "1.2.3" > .zig-version
  run zigenv-local
  assert_success
  assert_output "1.2.3"
}

@test "discovers version file in parent directory" {
  echo "1.2.3" > .zig-version
  mkdir -p "subdir" && cd "subdir"
  run zigenv-local
  assert_success
  assert_output "1.2.3"
}

@test "ignores ZIGENV_DIR" {
  echo "1.2.3" > .zig-version
  mkdir -p "$HOME"
  echo "2.0-home" > "${HOME}/.zig-version"
  ZIGENV_DIR="$HOME" run zigenv-local
  assert_success
  assert_output "1.2.3"
}

@test "sets local version" {
  mkdir -p "${ZIGENV_ROOT}/versions/1.2.3"
  run zigenv-local 1.2.3
  assert_success
  refute_output
  assert [ "$(cat .zig-version)" = "1.2.3" ]
}

@test "changes local version" {
  echo "1.0-pre" > .zig-version
  mkdir -p "${ZIGENV_ROOT}/versions/1.2.3"
  run zigenv-local
  assert_success
  assert_output "1.0-pre"
  run zigenv-local 1.2.3
  assert_success
  refute_output
  assert [ "$(cat .zig-version)" = "1.2.3" ]
}

@test "unsets local version" {
  touch .zig-version
  run zigenv-local --unset
  assert_success
  refute_output
  refute [ -e .zig-version ]
}
