#!/usr/bin/env bats

load test_helper

@test "no shims" {
  run zigenv-shims
  assert_success
  refute_output
}

@test "shims" {
  mkdir -p "${ZIGENV_ROOT}/shims"
  touch "${ZIGENV_ROOT}/shims/node"
  touch "${ZIGENV_ROOT}/shims/irb"
  run zigenv-shims
  assert_success
  assert_line "${ZIGENV_ROOT}/shims/node"
  assert_line "${ZIGENV_ROOT}/shims/irb"
}

@test "shims --short" {
  mkdir -p "${ZIGENV_ROOT}/shims"
  touch "${ZIGENV_ROOT}/shims/node"
  touch "${ZIGENV_ROOT}/shims/irb"
  run zigenv-shims --short
  assert_success
  assert_line "irb"
  assert_line "node"
}
