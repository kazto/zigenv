if [[ ! -o interactive ]]; then
    return
fi

compctl -K _zigenv zigenv

_zigenv() {
  local words completions
  read -cA words

  if [ "${#words}" -eq 2 ]; then
    completions="$(zigenv commands)"
  else
    completions="$(zigenv completions ${words[2,-2]})"
  fi

  reply=("${(ps:\n:)completions}")
}
