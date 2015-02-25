#!/bin/bash
PATH=$PATH:$HOME/bin
TTY=$(tty)

if [ "$TTY" = "$SSH_TTY" ]; then
	PS1="$(hostname -s)=ssh; "
else
	PS1="$(whoami)=; "
fi

export PATH PS1
