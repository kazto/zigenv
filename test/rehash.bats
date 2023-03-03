#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${ZIGENV_ROOT}/versions/${1}"
  local dir="$(dirname ${2})"
  mkdir -p "${bin}/${dir}"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "empty rehash" {
  assert [ ! -d "${ZIGENV_ROOT}/shims" ]
  run zigenv-rehash
  assert_success
  refute_output
  assert [ -d "${ZIGENV_ROOT}/shims" ]
  rmdir "${ZIGENV_ROOT}/shims"
}

@test "non-writable shims directory" {
  mkdir -p "${ZIGENV_ROOT}/shims"
  chmod -w "${ZIGENV_ROOT}/shims"
  run zigenv-rehash
  assert_failure
  assert_output "zigenv: cannot rehash: ${ZIGENV_ROOT}/shims isn't writable"
}

@test "rehash in progress" {
  mkdir -p "${ZIGENV_ROOT}/shims"
  touch "${ZIGENV_ROOT}/shims/.zigenv-shim"
  run zigenv-rehash
  assert_failure
  assert_output "zigenv: cannot rehash: ${ZIGENV_ROOT}/shims/.zigenv-shim exists"
}

@test "creates shims" {
  create_executable "0.10.26" "bin/node"
  create_executable "0.10.26" "bin/npm"
  create_executable "0.10.26" "zig"
  create_executable "0.11.11" "bin/node"
  create_executable "0.11.11" "bin/npm"
  create_executable "0.11.11" "zig"

  assert [ ! -e "${ZIGENV_ROOT}/shims/node" ]
  assert [ ! -e "${ZIGENV_ROOT}/shims/npm" ]
  assert [ ! -e "${ZIGENV_ROOT}/shims/zig" ]

  run zigenv-rehash
  assert_success
  refute_output

  run ls "${ZIGENV_ROOT}/shims"
  assert_success
  assert_output - <<OUT
node
npm
zig
OUT
}

@test "removes outdated shims" {
  mkdir -p "${ZIGENV_ROOT}/shims"
  touch "${ZIGENV_ROOT}/shims/oldshim1"
  chmod +x "${ZIGENV_ROOT}/shims/oldshim1"

  create_executable "2.0" "npm"
  create_executable "2.0" "node"

  run zigenv-rehash
  assert_success
  refute_output

  assert [ ! -e "${ZIGENV_ROOT}/shims/oldshim1" ]
}

@test "do exact matches when removing stale shims" {
  mkdir -p "${ZIGENV_ROOT}/shims"
  create_executable "2.0" "bin/unicorn_rails"
  create_executable "2.0" "bin/rspec-core"

  run zigenv-rehash
  assert [ -d "${ZIGENV_ROOT}/versions/2.0/bin" ]
  assert [ -e "${ZIGENV_ROOT}/shims/rspec-core" ]

  cp "$ZIGENV_ROOT"/shims/{rspec-core,rspec}
  cp "$ZIGENV_ROOT"/shims/{rspec-core,rails}
  cp "$ZIGENV_ROOT"/shims/{rspec-core,uni}
  chmod +x "$ZIGENV_ROOT"/shims/{rspec,rails,uni}

  run zigenv-rehash
  assert_success
  refute_output

  assert [ ! -e "${ZIGENV_ROOT}/shims/rails" ]
  assert [ ! -e "${ZIGENV_ROOT}/shims/rake" ]
  assert [ ! -e "${ZIGENV_ROOT}/shims/uni" ]
}

@test "binary install locations containing spaces" {
  mkdir -p "${ZIGENV_ROOT}/shims"
  create_executable "dirname1 p247" "bin/node"
  create_executable "dirname2 preview1" "bin/npm"

  assert [ ! -e "${ZIGENV_ROOT}/shims/node" ]
  assert [ ! -e "${ZIGENV_ROOT}/shims/npm" ]

  run zigenv-rehash
  assert_success
  refute_output

  run ls "${ZIGENV_ROOT}/shims"
  assert_success
  assert_output - <<OUT
node
npm
OUT
}

@test "carries original IFS within hooks" {
  create_hook rehash hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  IFS=$' \t\n' run zigenv-rehash
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

@test "sh-rehash in bash" {
  mkdir -p "${ZIGENV_ROOT}/shims"
  create_executable "2.0" "bin/node"
  ZIGENV_SHELL=bash run zigenv-sh-rehash
  assert_success
  assert_output "hash -r 2>/dev/null || true"
  assert [ -x "${ZIGENV_ROOT}/shims/node" ]
}

@test "sh-rehash in fish" {
  mkdir -p "${ZIGENV_ROOT}/shims"
  create_executable "2.0" "bin/node"
  ZIGENV_SHELL=fish run zigenv-sh-rehash
  assert_success
  refute_output
  assert [ -x "${ZIGENV_ROOT}/shims/node" ]
}
