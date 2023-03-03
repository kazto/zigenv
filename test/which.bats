#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin
  if [[ $1 == */* ]]; then bin="$1"
  else bin="${ZIGENV_ROOT}/versions/${1}/bin"
  fi
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "outputs path to executable" {
  create_executable "1.8" "node"
  create_executable "2.0" "npm"

  ZIGENV_VERSION=1.8 run zigenv-which node
  assert_success
  assert_output "${ZIGENV_ROOT}/versions/1.8/bin/node"

  ZIGENV_VERSION=2.0 run zigenv-which npm
  assert_success
  assert_output "${ZIGENV_ROOT}/versions/2.0/bin/npm"
}

@test "searches PATH for system version" {
  create_executable "${ZIGENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${ZIGENV_ROOT}/shims" "kill-all-humans"

  ZIGENV_VERSION=system run zigenv-which kill-all-humans
  assert_success
  assert_output "${ZIGENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims prepended)" {
  create_executable "${ZIGENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${ZIGENV_ROOT}/shims" "kill-all-humans"

  PATH="${ZIGENV_ROOT}/shims:$PATH" ZIGENV_VERSION=system run zigenv-which kill-all-humans
  assert_success
  assert_output "${ZIGENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims appended)" {
  create_executable "${ZIGENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${ZIGENV_ROOT}/shims" "kill-all-humans"

  PATH="$PATH:${ZIGENV_ROOT}/shims" ZIGENV_VERSION=system run zigenv-which kill-all-humans
  assert_success
  assert_output "${ZIGENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims spread)" {
  create_executable "${ZIGENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${ZIGENV_ROOT}/shims" "kill-all-humans"

  PATH="${ZIGENV_ROOT}/shims:${ZIGENV_ROOT}/shims:/tmp/non-existent:$PATH:${ZIGENV_ROOT}/shims" \
    ZIGENV_VERSION=system run zigenv-which kill-all-humans
  assert_success
  assert_output "${ZIGENV_TEST_DIR}/bin/kill-all-humans"
}

@test "doesn't include current directory in PATH search" {
  mkdir -p "$ZIGENV_TEST_DIR"
  cd "$ZIGENV_TEST_DIR"
  touch kill-all-humans
  chmod +x kill-all-humans
  PATH="$(path_without "kill-all-humans")" ZIGENV_VERSION=system run zigenv-which kill-all-humans
  assert_failure
  assert_output "zigenv: kill-all-humans: command not found"
}

@test "version not installed" {
  create_executable "2.0" "npm"
  ZIGENV_VERSION=1.9 run zigenv-which npm
  assert_failure
  assert_output "zigenv: version \`1.9' is not installed (set by ZIGENV_VERSION environment variable)"
}

@test "no executable found" {
  create_executable "1.8" "npm"
  ZIGENV_VERSION=1.8 run zigenv-which node
  assert_failure
  assert_output "zigenv: node: command not found"
}

@test "no executable found for system version" {
  PATH="$(path_without "mocha")" ZIGENV_VERSION=system run zigenv-which mocha
  assert_failure
  assert_output "zigenv: mocha: command not found"
}

@test "executable found in other versions" {
  create_executable "1.8" "node"
  create_executable "1.9" "npm"
  create_executable "2.0" "npm"

  ZIGENV_VERSION=1.8 run zigenv-which npm
  assert_failure
  assert_output - <<OUT
zigenv: npm: command not found

The \`npm' command exists in these Zig versions:
  1.9
  2.0
OUT
}

@test "carries original IFS within hooks" {
  create_hook which hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  IFS=$' \t\n' ZIGENV_VERSION=system run zigenv-which anything
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

@test "discovers version from zigenv-version-name" {
  mkdir -p "$ZIGENV_ROOT"
  cat > "${ZIGENV_ROOT}/version" <<<"1.8"
  create_executable "1.8" "node"

  mkdir -p "$ZIGENV_TEST_DIR"
  cd "$ZIGENV_TEST_DIR"

  ZIGENV_VERSION= run zigenv-which node
  assert_success
  assert_output "${ZIGENV_ROOT}/versions/1.8/bin/node"
}
