#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$ZIGENV_TEST_DIR"
  cd "$ZIGENV_TEST_DIR"
}

@test "reports global file even if it doesn't exist" {
  assert [ ! -e "${ZIGENV_ROOT}/version" ]
  run zigenv-version-origin
  assert_success
  assert_output "${ZIGENV_ROOT}/version"
}

@test "detects global file" {
  mkdir -p "$ZIGENV_ROOT"
  touch "${ZIGENV_ROOT}/version"
  run zigenv-version-origin
  assert_success
  assert_output "${ZIGENV_ROOT}/version"
}

@test "detects ZIGENV_VERSION" {
  ZIGENV_VERSION=1 run zigenv-version-origin
  assert_success
  assert_output "ZIGENV_VERSION environment variable"
}

@test "detects local file" {
  echo "system" > .zig-version
  run zigenv-version-origin
  assert_success
  assert_output "${PWD}/.zig-version"
}

@test "reports from hook" {
  create_hook version-origin test.bash <<<"ZIGENV_VERSION_ORIGIN=plugin"

  ZIGENV_VERSION=1 run zigenv-version-origin
  assert_success
  assert_output "plugin"
}

@test "carries original IFS within hooks" {
  create_hook version-origin hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export ZIGENV_VERSION=system
  IFS=$' \t\n' run zigenv-version-origin env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "doesn't inherit ZIGENV_VERSION_ORIGIN from environment" {
  ZIGENV_VERSION_ORIGIN=ignored run zigenv-version-origin
  assert_success
  assert_output "${ZIGENV_ROOT}/version"
}
