#!/usr/bin/env bats

load test_helper

@test "default" {
  run zigenv-global
  assert_success
  assert_output "system"
}

@test "read ZIGENV_ROOT/version" {
  mkdir -p "$ZIGENV_ROOT"
  echo "1.2.3" > "$ZIGENV_ROOT/version"
  run zigenv-global
  assert_success
  assert_output "1.2.3"
}

@test "set ZIGENV_ROOT/version" {
  mkdir -p "$ZIGENV_ROOT/versions/1.2.3"
  run zigenv-global "1.2.3"
  assert_success
  run zigenv-global
  assert_success
  assert_output "1.2.3"
}

@test "fail setting invalid ZIGENV_ROOT/version" {
  mkdir -p "$ZIGENV_ROOT"
  run zigenv-global "1.2.3"
  assert_failure
  assert_output "zigenv: version \`1.2.3' not installed"
}

@test "unset (remove) ZIGENV_ROOT/version" {
  mkdir -p "$ZIGENV_ROOT"
  echo "1.2.3" > "$ZIGENV_ROOT/version"

  run zigenv-global --unset
  assert_success

  refute [ -e $ZIGENV_ROOT/version ]
  run zigenv-global
  assert_output "system"
}
