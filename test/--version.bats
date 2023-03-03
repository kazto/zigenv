#!/usr/bin/env bats

load test_helper

export GIT_DIR="${ZIGENV_TEST_DIR}/.git"

setup() {
  mkdir -p "$HOME"
  git config --global user.name  "Tester"
  git config --global user.email "tester@test.local"
  cd "$ZIGENV_TEST_DIR"
}

git_commit() {
  git commit --quiet --allow-empty -m "empty"
}

@test "default version" {
  assert [ ! -e "$ZIGENV_ROOT" ]
  run zigenv---version
  assert_success
  [[ $output == "zigenv "?.?.? ]]
}

@test "doesn't read version from non-zigenv repo" {
  git init
  git remote add origin https://github.com/homebrew/homebrew.git
  git_commit
  git tag v1.0

  run zigenv---version
  assert_success
  [[ $output == "zigenv "?.?.? ]]
}

@test "reads version from git repo" {
  git init
  git remote add origin https://github.com/zigenv/zigenv.git
  git_commit
  git tag v0.4.1
  git_commit
  git_commit

  run zigenv---version
  assert_success
  assert_output "zigenv 0.4.1+2.$(git rev-parse --short HEAD)"
}

@test "prints default version if no tags in git repo" {
  git init
  git remote add origin https://github.com/zigenv/zigenv.git
  git_commit

  run zigenv---version
  [[ $output == "zigenv "?.?.? ]]
}
