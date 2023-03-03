#!/usr/bin/env bats

load test_helper

@test "prints usage help given no argument" {
  run zigenv-hooks
  assert_failure
  assert_output "Usage: zigenv hooks <command>"
}

@test "prints list of hooks" {
  path1="${ZIGENV_TEST_DIR}/zigenv.d"
  path2="${ZIGENV_TEST_DIR}/etc/zigenv_hooks"
  ZIGENV_HOOK_PATH="$path1"
  create_hook exec "hello.bash"
  create_hook exec "ahoy.bash"
  create_hook exec "invalid.sh"
  create_hook which "boom.bash"
  ZIGENV_HOOK_PATH="$path2"
  create_hook exec "bueno.bash"

  ZIGENV_HOOK_PATH="$path1:$path2" run zigenv-hooks exec
  assert_success
  assert_output - <<OUT
${ZIGENV_TEST_DIR}/zigenv.d/exec/ahoy.bash
${ZIGENV_TEST_DIR}/zigenv.d/exec/hello.bash
${ZIGENV_TEST_DIR}/etc/zigenv_hooks/exec/bueno.bash
OUT
}

@test "supports hook paths with spaces" {
  path1="${ZIGENV_TEST_DIR}/my hooks/zigenv.d"
  path2="${ZIGENV_TEST_DIR}/etc/zigenv hooks"
  ZIGENV_HOOK_PATH="$path1"
  create_hook exec "hello.bash"
  ZIGENV_HOOK_PATH="$path2"
  create_hook exec "ahoy.bash"

  ZIGENV_HOOK_PATH="$path1:$path2" run zigenv-hooks exec
  assert_success
  assert_output - <<OUT
${ZIGENV_TEST_DIR}/my hooks/zigenv.d/exec/hello.bash
${ZIGENV_TEST_DIR}/etc/zigenv hooks/exec/ahoy.bash
OUT
}

@test "resolves relative paths" {
  ZIGENV_HOOK_PATH="${ZIGENV_TEST_DIR}/zigenv.d"
  create_hook exec "hello.bash"
  mkdir -p "$HOME"

  ZIGENV_HOOK_PATH="${HOME}/../zigenv.d" run zigenv-hooks exec
  assert_success
  assert_output "${ZIGENV_TEST_DIR}/zigenv.d/exec/hello.bash"
}

@test "resolves symlinks" {
  path="${ZIGENV_TEST_DIR}/zigenv.d"
  mkdir -p "${path}/exec"
  mkdir -p "$HOME"
  touch "${HOME}/hola.bash"
  ln -s "../../home/hola.bash" "${path}/exec/hello.bash"
  touch "${path}/exec/bright.sh"
  ln -s "bright.sh" "${path}/exec/world.bash"

  ZIGENV_HOOK_PATH="$path" run zigenv-hooks exec
  assert_success
  assert_output - <<OUT
${HOME}/hola.bash
${ZIGENV_TEST_DIR}/zigenv.d/exec/bright.sh
OUT
}
