tabstop=4
EDITOR="9 F"
P9P=$(9 sh -c 'echo $PLAN9')

# we need this so we can use osx fonts in acme, install if it doesn't exist
[[ -e $P9P/bin/fontsrv ]] || (cd $P9P/src/cmd/fontsrv && 9 mk install)

# launch plumber
pgrep -q plumber || 9 plumber
[[ -d $HOME/lib ]] || mkdir -p $HOME/lib
9 9p read plumb/rules | sed 's/^editor\=.*/editor=acme2/g' > $HOME/lib/plumber.$$
9 9p write plumb/rules < $HOME/lib/plumber.$$
rm -f $HOME/lib/plumber.$$

export tabstop font EDITOR P9P
