GOPATH=$HOME/go
PATH=$PATH:$GOPATH/bin
CDPATH=$CDPATH:$GOPATH/src

[[ -d $GOPATH ]] || mkdir -p $GOPATH

alias gocd='cd $GOPATH/src/*/$USER'
export GOPATH PATH CDPATH
