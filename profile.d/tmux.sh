# better integration with iTerm2

function tmux_run()
{
	name=$1
	session=$(tmux ls|awk -F":" '$1 ~ /^'$name'$/ {print $1}')
	if [ "$name" = "$session" ]; then
		tmux -CC attach -t $name
	else
		tmux -CC new -t $name
	fi
}

alias ti='tmux_run $ITERM_BASE'

export ITERM_BASE