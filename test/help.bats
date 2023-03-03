#!/usr/bin/env bats

load test_helper

@test "without args shows summary of common commands" {
  run zigenv-help
  assert_success
  assert_line "Usage: zigenv <command> [<args>]"
  assert_line "Some useful zigenv commands are:"
}

@test "invalid command" {
  run zigenv-help hello
  assert_failure
  assert_output "zigenv: no such command \`hello'"
}

@test "shows help for a specific command" {
  mkdir -p "${ZIGENV_TEST_DIR}/bin"
  cat > "${ZIGENV_TEST_DIR}/bin/zigenv-hello" <<SH
#!shebang
# Usage: zigenv hello <world>
# Summary: Says "hello" to you, from zigenv
# This command is useful for saying hello.
echo hello
SH

  run zigenv-help hello
  assert_success
  assert_output - <<SH
Usage: zigenv hello <world>

This command is useful for saying hello.
SH
}

@test "replaces missing extended help with summary text" {
  mkdir -p "${ZIGENV_TEST_DIR}/bin"
  cat > "${ZIGENV_TEST_DIR}/bin/zigenv-hello" <<SH
#!shebang
# Usage: zigenv hello <world>
# Summary: Says "hello" to you, from zigenv
echo hello
SH

  run zigenv-help hello
  assert_success
  assert_output - <<SH
Usage: zigenv hello <world>

Says "hello" to you, from zigenv
SH
}

@test "extracts only usage" {
  mkdir -p "${ZIGENV_TEST_DIR}/bin"
  cat > "${ZIGENV_TEST_DIR}/bin/zigenv-hello" <<SH
#!shebang
# Usage: zigenv hello <world>
# Summary: Says "hello" to you, from zigenv
# This extended help won't be shown.
echo hello
SH

  run zigenv-help --usage hello
  assert_success
  assert_output "Usage: zigenv hello <world>"
}

@test "multiline usage section" {
  mkdir -p "${ZIGENV_TEST_DIR}/bin"
  cat > "${ZIGENV_TEST_DIR}/bin/zigenv-hello" <<SH
#!shebang
# Usage: zigenv hello <world>
#        zigenv hi [everybody]
#        zigenv hola --translate
# Summary: Says "hello" to you, from zigenv
# Help text.
echo hello
SH

  run zigenv-help hello
  assert_success
  assert_output - <<SH
Usage: zigenv hello <world>
       zigenv hi [everybody]
       zigenv hola --translate

Help text.
SH
}

@test "multiline extended help section" {
  mkdir -p "${ZIGENV_TEST_DIR}/bin"
  cat > "${ZIGENV_TEST_DIR}/bin/zigenv-hello" <<SH
#!shebang
# Usage: zigenv hello <world>
# Summary: Says "hello" to you, from zigenv
# This is extended help text.
# It can contain multiple lines.
#
# And paragraphs.

echo hello
SH

  run zigenv-help hello
  assert_success
  assert_output - <<SH
Usage: zigenv hello <world>

This is extended help text.
It can contain multiple lines.

And paragraphs.
SH
}
