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

DOCK_MOD="
<dict> <key>tile-data</key> <dict> <key>file-data</key> 
<dict> <key>_CFURLString</key> <string>%s</string> 
<key>_CFURLStringType</key> <integer>0</integer> </dict> 
</dict> </dict>"

BREWS="
	caskroom/cask/brew-cask
	plan9port
	go
	postgresql
	tmux
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
	echo "--> Dotfiles home $HOME/.profile.d already exists, skipping"
else
	echo "--> Populating dotfiles"
	cmd=$(grep -o 'for profile in $HOME/.profile.d/*.sh; do source $profile; done' $HOME/.profile)
	if [ -z "$cmd" ]; then
		echo 'for profile in $HOME/.profile.d/*.sh; do source $profile; done' >> $HOME/.profile
	else
		echo 'already there'
	fi
fi
