function __fish_zigenv_needs_command
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 -a $cmd[1] = 'zigenv' ]
    return 0
  end
  return 1
end

function __fish_zigenv_using_command
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    if [ $argv[1] = $cmd[2] ]
      return 0
    end
  end
  return 1
end

complete -f -c zigenv -n '__fish_zigenv_needs_command' -a '(zigenv commands)'
for cmd in (zigenv commands)
  complete -f -c zigenv -n "__fish_zigenv_using_command $cmd" -a \
    "(zigenv completions (commandline -opc)[2..-1])"
end
