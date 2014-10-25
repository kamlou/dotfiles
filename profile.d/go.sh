GOPATH=$HOME/go
PATH=$PATH:$GOPATH/bin

[[ -d $GOPATH ]] || mkdir -p $GOPATH

alias gocd='cd $GOPATH/src/*/$USER'
export GOPATH PATH
