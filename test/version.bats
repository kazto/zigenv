#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${ZIGENV_ROOT}/versions/$1"
}

alias_version() {
  ln -sf "$ZIGENV_ROOT/versions/$2" "$ZIGENV_ROOT/versions/$1"
}

setup() {
  mkdir -p "$ZIGENV_TEST_DIR"
  cd "$ZIGENV_TEST_DIR"
}

@test "no version selected" {
  assert [ ! -d "${ZIGENV_ROOT}/versions" ]
  run zigenv-version
  assert_success
  assert_output "system (set by ${ZIGENV_ROOT}/version)"
}

@test "using a symlink/alias" {
  create_version 1.9.3
  alias_version 1.9 1.9.3

  ZIGENV_VERSION=1.9 run zigenv-version

  assert_success
  assert_output "1.9 => 1.9.3 (set by ZIGENV_VERSION environment variable)"
}

@test "links to links resolve the final target" {
  create_version 1.9.3
  alias_version 1.9 1.9.3
  alias_version 1 1.9

  ZIGENV_VERSION=1 run zigenv-version

  assert_success
  assert_output "1 => 1.9.3 (set by ZIGENV_VERSION environment variable)"
}

@test "set by ZIGENV_VERSION" {
  create_version "1.9.3"
  ZIGENV_VERSION=1.9.3 run zigenv-version
  assert_success
  assert_output "1.9.3 (set by ZIGENV_VERSION environment variable)"
}

@test "set by local file" {
  create_version "1.9.3"
  cat > ".zig-version" <<<"1.9.3"
  run zigenv-version
  assert_success
  assert_output "1.9.3 (set by ${PWD}/.zig-version)"
}

@test "set by global file" {
  create_version "1.9.3"
  cat > "${ZIGENV_ROOT}/version" <<<"1.9.3"
  run zigenv-version
  assert_success
  assert_output "1.9.3 (set by ${ZIGENV_ROOT}/version)"
}
