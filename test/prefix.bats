#!/usr/bin/env bats

load test_helper

@test "prefix" {
  mkdir -p "${ZIGENV_TEST_DIR}/myproject"
  cd "${ZIGENV_TEST_DIR}/myproject"
  echo "1.2.3" > .zig-version
  mkdir -p "${ZIGENV_ROOT}/versions/1.2.3"
  run zigenv-prefix
  assert_success
  assert_output "${ZIGENV_ROOT}/versions/1.2.3"
}

@test "prefix for invalid version" {
  ZIGENV_VERSION="1.2.3" run zigenv-prefix
  assert_failure
  assert_output "zigenv: version \`1.2.3' not installed"
}

@test "prefix for system" {
  mkdir -p "${ZIGENV_TEST_DIR}/bin"
  touch "${ZIGENV_TEST_DIR}/bin/node"
  chmod +x "${ZIGENV_TEST_DIR}/bin/node"
  ZIGENV_VERSION="system" run zigenv-prefix
  assert_success
  assert_output "$ZIGENV_TEST_DIR"
}

@test "prefix for system in /" {
  mkdir -p "${BATS_TEST_DIRNAME}/libexec"
  cat >"${BATS_TEST_DIRNAME}/libexec/zigenv-which" <<OUT
#!/bin/sh
echo /bin/node
OUT
  chmod +x "${BATS_TEST_DIRNAME}/libexec/zigenv-which"
  ZIGENV_VERSION="system" run zigenv-prefix
  assert_success
  assert_output "/"
  rm -f "${BATS_TEST_DIRNAME}/libexec/zigenv-which"
}

@test "prefix for invalid system" {
  PATH="$(path_without node)" run zigenv-prefix system
  assert_failure
  assert_output - <<EOF
zigenv: node: command not found
zigenv: system version not found in PATH
EOF
}
