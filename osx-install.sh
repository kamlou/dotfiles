#!/bin/sh

# fail fast 
set -e 
exec 2>&1

case $(uname -s) in
	Darwin)
		echo "--> Installing packages on OSX.."
	;;
	*)
		echo "--> system not supported $(uname -s)"
		exit 1
	;;
esac

function errf()
{
	r=$?
	cmd="$BASH_COMMAND"
	line="${BASH_LINENO[0]}"
	echo "--> Barfed at $cmd:$line, exiting"
	exit $r
}

function skipcopy()
{
	f1=$1
	f2=$2
	cmp -s $f1 $f2
	if [ $? -ne 0 ]; then
		echo "--> .. $(basename $f1)"
		return 1
	else
		echo "--> .. skipping $(basename $f1)"
		return 0
	fi
}

trap errf ERR

DOCK_MOD="
<dict> <key>tile-data</key> <dict> <key>file-data</key> 
<dict> <key>_CFURLString</key> <string>%s</string> 
<key>_CFURLStringType</key> <integer>0</integer> </dict> 
</dict> </dict>"

BREWS="
	caskroom/cask/brew-cask
	plan9port
	go
	postgresql93
	tmux
	hub
	bzr
	s3cmd
	lastpass-cli
	todo-txt
	hub
	gist
"

CASKS="
	virtualbox
	iterm2
	textmate
	boot2docker
	vagrant
"

# install homebrew
echo "--> Installing Homebrew and Casks.."
if [ "$(which brew)" = "" ]; then
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
	echo "--> Brew v$(brew config|awk '/HOMEBREW_VERSION/ {print $2}') found, updating" 
	brew update
fi

for formula in $BREWS; do
	brew list $formula >/dev/null || brew install $formula
done

for cask in $CASKS; do
	brew cask list $cask >/dev/null || brew cask install $cask
done

echo "--> Installing RVM"
# install rvm
if [ -z "$(which rvm)" ]; then
	\curl -sSL https://get.rvm.io | bash -s stable --ruby
else
	echo "--> RVM v$(rvm version|awk '{print $2}') found, to update run: rvm get stable"
fi

echo "--> Updating apps on the Dock.."
registered_apps=""
for app in $HOME/Applications/*.app; do
	app_dict=$(printf "$DOCK_MOD" $app)
	name=$(defaults read com.apple.dock persistent-apps|grep -o $(basename $app))
	
	if [ -z "$name" ]; then
		defaults write com.apple.dock persistent-apps -array-add "$app_dict"
		registered_apps="$registered_apps $(basename $app)"
		echo "--> Registering $(basename $app)"
	else
		echo "--> $(basename $app) is already registered with the Dock"
	fi
done

if [ -n "$registered_apps" ]; then
	echo "--> Restarting the Dock.."
	killall -KILL Dock
else
	echo "--> No new apps to be registered.."
fi

# setting up dot files
if [ -d $HOME/.profile.d ]; then
	echo "--> ! Dotfiles home $HOME/.profile.d already exists, updating"
else
	mkdir -p $HOME/.profile.d
fi

if [ ! $(egrep -o '\.profile\.d' $HOME/.profile) ]; then
	echo '--> Enabling $HOME/.profile.d in $HOME/.profile ..'
	echo 'for profile in $HOME/.profile.d/*.sh; do source $profile; done' >> $HOME/.profile
fi

echo "--> Populating dotfiles"
for f in ./profile.d/*; do
	skipcopy $f $HOME/.profile.d/$(basename $f) || cp -p $f $HOME/.profile.d
done

# load bin files
echo "--> Installing scripts into $HOME/bin"
[[ -d $HOME/bin ]] || mkdir -p $HOME/bin
if [ -d $HOME/bin ]; then
	for f in ./scripts/*; do
		skipcopy $f $HOME/bin/$(basename $f) || (cp -p $f $HOME/bin && chmod +x $HOME/bin/$(basename $f))
	done
fi
