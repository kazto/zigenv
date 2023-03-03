#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$ZIGENV_TEST_DIR"
  cd "$ZIGENV_TEST_DIR"
}

create_file() {
  mkdir -p "$(dirname "$1")"
  echo "system" > "$1"
}

@test "detects global 'version' file" {
  create_file "${ZIGENV_ROOT}/version"
  run zigenv-version-file
  assert_success
  assert_output "${ZIGENV_ROOT}/version"
}

@test "prints global file if no version files exist" {
  refute [ -e "${ZIGENV_ROOT}/version" ]
  refute [ -e ".zig-version" ]
  run zigenv-version-file
  assert_success
  assert_output "${ZIGENV_ROOT}/version"
}

@test "in current directory" {
  create_file ".zig-version"
  run zigenv-version-file
  assert_success
  assert_output "${ZIGENV_TEST_DIR}/.zig-version"
}

@test "in parent directory" {
  create_file ".zig-version"
  mkdir -p project
  cd project
  run zigenv-version-file
  assert_success
  assert_output "${ZIGENV_TEST_DIR}/.zig-version"
}

@test "topmost file has precedence" {
  create_file ".zig-version"
  create_file "project/.zig-version"
  cd project
  run zigenv-version-file
  assert_success
  assert_output "${ZIGENV_TEST_DIR}/project/.zig-version"
}

@test "ZIGENV_DIR has precedence over PWD" {
  create_file "widget/.zig-version"
  create_file "project/.zig-version"
  cd project
  ZIGENV_DIR="${ZIGENV_TEST_DIR}/widget" run zigenv-version-file
  assert_success
  assert_output "${ZIGENV_TEST_DIR}/widget/.zig-version"
}

@test "PWD is searched if ZIGENV_DIR yields no results" {
  mkdir -p "widget/blank"
  create_file "project/.zig-version"
  cd project
  ZIGENV_DIR="${ZIGENV_TEST_DIR}/widget/blank" run zigenv-version-file
  assert_success
  assert_output "${ZIGENV_TEST_DIR}/project/.zig-version"
}

@test "finds version file in target directory" {
  create_file "project/.zig-version"
  run zigenv-version-file "${PWD}/project"
  assert_success
  assert_output "${ZIGENV_TEST_DIR}/project/.zig-version"
}

@test "fails when no version file in target directory" {
  run zigenv-version-file "$PWD"
  assert_failure
  refute_output
}
