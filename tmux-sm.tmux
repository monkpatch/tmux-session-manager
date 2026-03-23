#!/usr/bin/env bash

default_key_binding="@session_manager_key"
key_binding_option="$(tmux show-option -gqv "$default_key_binding")"
key_binding="${key_binding_option:-"j"}"

tmux bind-key "$key_binding" display-popup -E -w 80% -h 60% -T ' tmux-session-manager ' '
  cmd='"'"'
  tmux list-sessions -F "#{session_activity}|#{session_name}|#{session_windows}|#{?session_attached,attached,detached}" | 
  sort -r | 
  grep -v "^[^|]*|$(tmux display-message -p "#S")|" | 
  awk -F"|" "{
    status = (\$4 == \"attached\") ? \"\" : \"\"
    printf \"%-20s %s %2s windows %s\\n\", \$2, status, \$3, \"\"
  }"
  '"'"'
  sh -c "$cmd" |
  fzf --reverse \
      --prompt="-> " \
      --header="═══ Session Switcher ═══ | Alt-Enter: new-session | Alt-Backspace: delete" \
      --header-first \
      --border=rounded \
      --color="header:italic" \
      --tiebreak=index \
      --preview="tmux list-windows -t {1} -F \"  #{window_index}: #{window_name} #{?window_active,(active),}\"" \
      --preview-window="right:40%:wrap" \
      --bind="alt-backspace:execute(tmux kill-session -t {1})+reload($cmd)" \
      --bind="alt-enter:execute(tmux new-session -d -s {q} 2>/dev/null && tmux switch-client -t {q})+abort" \
      --info=inline \
      --layout=reverse |
  awk "{print \$1}" | 
  xargs -r tmux switch-client -t
'
