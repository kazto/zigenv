#!/usr/bin/env bats

load test_helper

@test "creates shims and versions directories" {
  assert [ ! -d "${ZIGENV_ROOT}/shims" ]
  assert [ ! -d "${ZIGENV_ROOT}/versions" ]
  run zigenv-init -
  assert_success
  assert [ -d "${ZIGENV_ROOT}/shims" ]
  assert [ -d "${ZIGENV_ROOT}/versions" ]
}

@test "auto rehash" {
  run zigenv-init -
  assert_success
  assert_line "command zigenv rehash 2>/dev/null"
}

@test "setup shell completions" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run zigenv-init - bash
  assert_success
  assert_line "source '${root}/test/../libexec/../completions/zigenv.bash'"
}

@test "detect parent shell" {
  SHELL=/bin/false run zigenv-init -
  assert_success
  assert_line "export ZIGENV_SHELL=bash"
}

@test "detect parent shell from script" {
  mkdir -p "$ZIGENV_TEST_DIR"
  cd "$ZIGENV_TEST_DIR"
  cat > myscript.sh <<OUT
#!/bin/sh
eval "\$(zigenv-init -)"
echo \$ZIGENV_SHELL
OUT
  chmod +x myscript.sh
  run ./myscript.sh /bin/zsh
  assert_success
  assert_output "sh"
}

@test "setup shell completions (fish)" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run zigenv-init - fish
  assert_success
  assert_line "source '${root}/test/../libexec/../completions/zigenv.fish'"
}

@test "fish instructions" {
  run zigenv-init fish
  assert_failure 1
  assert_line 'status --is-interactive; and source (zigenv init -|psub)'
}

@test "option to skip rehash" {
  run zigenv-init - --no-rehash
  assert_success
  refute_line "zigenv rehash 2>/dev/null"
}

@test "adds shims to PATH" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run zigenv-init - bash
  assert_success
  assert_line -n 0 'export PATH="'${ZIGENV_ROOT}'/shims:${PATH}"'
}

@test "adds shims to PATH (fish)" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run zigenv-init - fish
  assert_success
  assert_line -n 0 "set -gx PATH '${ZIGENV_ROOT}/shims' \$PATH"
}

@test "can add shims to PATH more than once" {
  export PATH="${ZIGENV_ROOT}/shims:$PATH"
  run zigenv-init - bash
  assert_success
  assert_line -n 0 'export PATH="'${ZIGENV_ROOT}'/shims:${PATH}"'
}

@test "can add shims to PATH more than once (fish)" {
  export PATH="${ZIGENV_ROOT}/shims:$PATH"
  run zigenv-init - fish
  assert_success
  assert_line -n 0 "set -gx PATH '${ZIGENV_ROOT}/shims' \$PATH"
}

@test "outputs sh-compatible syntax" {
  run zigenv-init - bash
  assert_success
  assert_line '  case "$command" in'

  run zigenv-init - zsh
  assert_success
  assert_line '  case "$command" in'
}

@test "outputs fish-specific syntax (fish)" {
  run zigenv-init - fish
  assert_success
  assert_line '  switch "$command"'
  refute_line '  case "$command" in'
}
