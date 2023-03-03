#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${ZIGENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$ZIGENV_TEST_DIR"
  cd "$ZIGENV_TEST_DIR"
}

@test "no version selected" {
  assert [ ! -d "${ZIGENV_ROOT}/versions" ]
  run zigenv-version-name
  assert_success
  assert_output "system"
}

@test "system version is not checked for existance" {
  ZIGENV_VERSION=system run zigenv-version-name
  assert_success
  assert_output "system"
}

@test "ZIGENV_VERSION can be overridden by hook" {
  create_version "1.8.7"
  create_version "1.9.3"
  create_hook version-name test.bash <<<"ZIGENV_VERSION=1.9.3"

  ZIGENV_VERSION=1.8.7 run zigenv-version-name
  assert_success
  assert_output "1.9.3"
}

@test "carries original IFS within hooks" {
  create_hook version-name hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export ZIGENV_VERSION=system
  IFS=$' \t\n' run zigenv-version-name env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "ZIGENV_VERSION has precedence over local" {
  create_version "1.8.7"
  create_version "1.9.3"

  cat > ".zig-version" <<<"1.8.7"
  run zigenv-version-name
  assert_success
  assert_output "1.8.7"

  ZIGENV_VERSION=1.9.3 run zigenv-version-name
  assert_success
  assert_output "1.9.3"
}

@test "local file has precedence over global" {
  create_version "1.8.7"
  create_version "1.9.3"

  cat > "${ZIGENV_ROOT}/version" <<<"1.8.7"
  run zigenv-version-name
  assert_success
  assert_output "1.8.7"

  cat > ".zig-version" <<<"1.9.3"
  run zigenv-version-name
  assert_success
  assert_output "1.9.3"
}

@test "missing version" {
  ZIGENV_VERSION=1.2 run zigenv-version-name
  assert_failure
  assert_output "zigenv: version \`1.2' is not installed (set by ZIGENV_VERSION environment variable)"
}

@test "version with prefix in name" {
  create_version "1.8.7"
  cat > ".zig-version" <<<"node-1.8.7"
  run zigenv-version-name
  assert_success
  assert_output "1.8.7"
}

@test "version with 'v' prefix in name" {
  create_version "4.1.0"
  cat > ".zig-version" <<<"v4.1.0"
  run zigenv-version-name
  assert_success
  assert_output "4.1.0"
}

@test "version with 'node-v' prefix in name" {
  create_version "4.1.0"
  cat > ".zig-version" <<<"node-v4.1.0"
  run zigenv-version-name
  assert_success
  assert_output "4.1.0"
}

@test "iojs version with 'v' prefix in name" {
  create_version "iojs-3.1.0"
  cat > ".zig-version" <<<"iojs-v3.1.0"
  run zigenv-version-name
  assert_success
  assert_output "iojs-3.1.0"
}
