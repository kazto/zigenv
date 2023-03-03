#!/usr/bin/env bats

load test_helper

@test "blank invocation" {
  run zigenv
  assert_failure
  assert_line -n 0 "$(zigenv---version)"
}

@test "invalid command" {
  run zigenv does-not-exist
  assert_failure
  assert_output "zigenv: no such command \`does-not-exist'"
}

@test "default ZIGENV_ROOT" {
  ZIGENV_ROOT="" HOME=/home/will run zigenv root
  assert_success
  assert_output "/home/will/.zigenv"
}

@test "inherited ZIGENV_ROOT" {
  ZIGENV_ROOT=/opt/zigenv run zigenv root
  assert_success
  assert_output "/opt/zigenv"
}

@test "default ZIGENV_DIR" {
  run zigenv echo ZIGENV_DIR
  assert_output "$(pwd)"
}

@test "inherited ZIGENV_DIR" {
  dir="${BATS_TMPDIR}/myproject"
  mkdir -p "$dir"
  ZIGENV_DIR="$dir" run zigenv echo ZIGENV_DIR
  assert_output "$dir"
}

@test "invalid ZIGENV_DIR" {
  dir="${BATS_TMPDIR}/does-not-exist"
  assert [ ! -d "$dir" ]
  ZIGENV_DIR="$dir" run zigenv echo ZIGENV_DIR
  assert_failure
  assert_output "zigenv: cannot change working directory to \`$dir'"
}

@test "adds its own libexec to PATH" {
  run zigenv echo "PATH"
  assert_success
  assert_output "${BATS_TEST_DIRNAME%/*}/libexec:$PATH"
}

@test "adds plugin bin dirs to PATH" {
  mkdir -p "$ZIGENV_ROOT"/plugins/node-build/bin
  mkdir -p "$ZIGENV_ROOT"/plugins/zigenv-each/bin
  run zigenv echo -F: "PATH"
  assert_success
  assert_line -n 0 "${BATS_TEST_DIRNAME%/*}/libexec"
  assert_line -n 1 "${ZIGENV_ROOT}/plugins/zigenv-each/bin"
  assert_line -n 2 "${ZIGENV_ROOT}/plugins/node-build/bin"
}

@test "ZIGENV_HOOK_PATH preserves value from environment" {
  ZIGENV_HOOK_PATH=/my/hook/path:/other/hooks run zigenv echo -F: "ZIGENV_HOOK_PATH"
  assert_success
  assert_line -n 0 "/my/hook/path"
  assert_line -n 1 "/other/hooks"
  assert_line -n 2 "${ZIGENV_ROOT}/zigenv.d"
}

@test "ZIGENV_HOOK_PATH includes zigenv built-in plugins" {
  unset ZIGENV_HOOK_PATH
  run zigenv echo "ZIGENV_HOOK_PATH"
  assert_success
  assert_output "${ZIGENV_ROOT}/zigenv.d:${BATS_TEST_DIRNAME%/*}/zigenv.d:/usr/local/etc/zigenv.d:/etc/zigenv.d:/usr/lib/zigenv/hooks"
}
