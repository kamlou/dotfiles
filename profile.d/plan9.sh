font=/mnt/font/Verdana/13a/font
tabstop=4
alias acme="9 acme -f $font -l $HOME/acme.dump"
EDITOR="9 F"
P9P=$(9 sh -c 'echo $PLAN9')

# we need this so we can use osx fonts in acme, install if it doesn't exist
[[ -e $P9P/bin/fontsrv ]] || (cd $P9P/src/cmd/fontsrv && 9 mk install)
[[ ! -f $HOME/acme.dump ]] || touch $HOME/.acme.dump

# launch plumber
pgrep -q plumber || plumber

export tabstop font EDITOR P9P
