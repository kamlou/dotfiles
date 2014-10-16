# better integration with iTerm2

ITERM_BASE=iterm2

function tmux_run()
{
	name=$1
	session=$(tmux ls|awk -F":" '$1 ~ /^'$name'$/ {print $1}')
	if [ "$name" = "$session" ]; then
		tmux -CC attach -t $name
	else
		tmux -CC new -s $name
	fi
}

export ITERM_BASE

alias ti='tmux_run $ITERM_BASE'

