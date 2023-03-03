load ../node_modules/bats-support/load
load ../node_modules/bats-assert/load

unset ZIGENV_VERSION
unset ZIGENV_DIR

# guard against executing this block twice due to bats internals
if [ -z "$ZIGENV_TEST_DIR" ]; then
  ZIGENV_TEST_DIR="${BATS_TMPDIR}/zigenv"
  ZIGENV_TEST_DIR="$(mktemp -d "${ZIGENV_TEST_DIR}.XXX" 2>/dev/null || echo "$ZIGENV_TEST_DIR")"
  export ZIGENV_TEST_DIR

  ZIGENV_REALPATH=$BATS_TEST_DIRNAME/../libexec/zigenv-realpath.dylib

  if enable -f "$ZIGENV_REALPATH" realpath 2>/dev/null; then
    ZIGENV_TEST_DIR="$(realpath "$ZIGENV_TEST_DIR")"
  else
    if [ -x "$ZIGENV_REALPATH" ]; then
      echo "zigenv: failed to load \`realpath' builtin" >&2
      exit 1
    fi
  fi

  export ZIGENV_ROOT="${ZIGENV_TEST_DIR}/root"
  export HOME="${ZIGENV_TEST_DIR}/home"
  export ZIGENV_HOOK_PATH=$ZIGENV_ROOT/zigenv.d:$BATS_TEST_DIRNAME/../zigenv.d

  PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin
  PATH="${ZIGENV_TEST_DIR}/bin:$PATH"
  PATH="${BATS_TEST_DIRNAME}/../libexec:$PATH"
  PATH="${BATS_TEST_DIRNAME}/libexec:$PATH"
  PATH="${ZIGENV_ROOT}/shims:$PATH"
  export PATH

  for xdg_var in $(env 2>/dev/null | grep ^XDG_ | cut -d= -f1); do unset "$xdg_var"; done
  unset xdg_var
fi

teardown() {
  rm -rf "$ZIGENV_TEST_DIR"
}

# Output a modified PATH that ensures that the given executable is not present,
# but in which system utils necessary for zigenv operation are still available.
path_without() {
  local exe="$1"
  local path=":${PATH}:"
  local found alt util
  for found in $(which -a "$exe"); do
    found="${found%/*}"
    if [ "$found" != "${ZIGENV_ROOT}/shims" ]; then
      alt="${ZIGENV_TEST_DIR}/$(echo "${found#/}" | tr '/' '-')"
      mkdir -p "$alt"
      for util in bash head cut readlink greadlink; do
        if [ -x "${found}/$util" ]; then
          ln -s "${found}/$util" "${alt}/$util"
        fi
      done
      path="${path/:${found}:/:${alt}:}"
    fi
  done
  path="${path#:}"
  echo "${path%:}"
}

create_hook() {
  local hook_path=${ZIGENV_HOOK_PATH%%:*}
  mkdir -p "${hook_path:?}/$1"
  touch "${hook_path:?}/$1/$2"
  if [ ! -t 0 ]; then
    cat > "${hook_path:?}/$1/$2"
  fi
}
