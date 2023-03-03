#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$ZIGENV_TEST_DIR"
  cd "$ZIGENV_TEST_DIR"
}

@test "invocation without 2 arguments prints usage" {
  run zigenv-version-file-write
  assert_failure
  assert_output "Usage: zigenv version-file-write <file> <version>"
  run zigenv-version-file-write "one" ""
  assert_failure
}

@test "setting nonexistent version fails" {
  assert [ ! -e ".zig-version" ]
  run zigenv-version-file-write ".zig-version" "1.8.7"
  assert_failure
  assert_output "zigenv: version \`1.8.7' not installed"
  assert [ ! -e ".zig-version" ]
}

@test "writes value to arbitrary file" {
  mkdir -p "${ZIGENV_ROOT}/versions/1.8.7"
  assert [ ! -e "my-version" ]
  run zigenv-version-file-write "${PWD}/my-version" "1.8.7"
  assert_success
  refute_output
  assert [ "$(cat my-version)" = "1.8.7" ]
}
