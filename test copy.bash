exec-and-forget bash -c 'aerospace move-node-to-workspace $(aerospace list-workspaces --monitor focused | sed '${n}q;d')'
