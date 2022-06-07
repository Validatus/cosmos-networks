```
#!/bin/bash

# Go destination  
#/usr/local/go/

# Go stable version 
VERSION="1.18.3"

# remove existing Go installation
DIR="/usr/local/go"
if [ -d "/usr/local/go" ]; then
   # Take action if $DIR exists. #
    echo "golang INSTALLATION in ${DIR}...❗"
    echo "going to remove previous Golang INSTALLATION in ${DIR}...❗"
    sudo rm -rf /usr/local/go
    sleep 2 
fi


# environment variable
[ -z "$GOROOT" ] && GOROOT="/usr/local/go/"
[ -z "$GOPATH" ] && GOPATH="$HOME/go"

OS="$(uname -s)"
ARCH="$(uname -m)"

case $OS in
    "Linux")
        case $ARCH in
        "x86_64")
            ARCH=amd64
            ;;
        "aarch64")
            ARCH=arm64
            ;;
        "armv6" | "armv7l")
            ARCH=armv6l
            ;;
        "armv8")
            ARCH=arm64
            ;;
        .*386.*)
            ARCH=386
            ;;
        esac
        PLATFORM="linux-$ARCH"
    ;;
    "Darwin")
        PLATFORM="darwin-amd64"
    ;;
esac

print_help() {
    echo "Usage: bash goBinaryInstall.sh OPTIONS"
    echo -e "\nOPTIONS:"
    echo -e "  --remove\tRemove currently installed version"
    echo -e "  --version\tSpecify a version number to install"
}

if [ -z "$PLATFORM" ]; then
    echo "Your operating system is not supported by the script."
    exit 1
fi

if [ -n "$($SHELL -c 'echo $ZSH_VERSION')" ]; then
    shell_profile="$HOME/.zshrc"
    global_profile="/etc/profile"
elif [ -n "$($SHELL -c 'echo $BASH_VERSION')" ]; then
    shell_profile="$HOME/.bashrc"
    global_profile="/etc/profile"
elif [ -n "$($SHELL -c 'echo $FISH_VERSION')" ]; then
    shell="fish"
    if [ -d "$XDG_CONFIG_HOME" ]; then
        shell_profile="$XDG_CONFIG_HOME/fish/config.fish"
        global_profile="/etc/profile"
    else
        shell_profile="$HOME/.config/fish/config.fish"
        global_profile="/etc/profile"
    fi
fi

if [ "$1" == "--remove" ]; then
    rm -rf "$GOROOT"
    if [ "$OS" == "Darwin" ]; then
        if [ "$shell" == "fish" ]; then
            sed -i "" '/# GoLang/d' "$shell_profile"
            sed -i "" '/set GOROOT/d' "$shell_profile"
            sed -i "" '/set GOPATH/d' "$shell_profile"
            sed -i "" '/set PATH $GOPATH\/bin $GOROOT\/bin $PATH/d' "$shell_profile"
            sed -i '/# GoLang/d' "$global_profile"
            sed -i '/PATH=\$PATH\:\/usr\/local\/go\/bin/d' "$global_profile"
        else
            sed -i "" '/# GoLang/d' "$shell_profile"
            sed -i "" '/export GOROOT/d' "$shell_profile"
            sed -i "" '/$GOROOT\/bin/d' "$shell_profile"
            sed -i "" '/export GOPATH/d' "$shell_profile"
            sed -i "" '/$GOPATH\/bin/d' "$shell_profile"
            sed -i '/# GoLang/d' "$global_profile"
            sed -i '/PATH=\$PATH\:\/usr\/local\/go\/bin/d' "$global_profile"
        fi
    else
        if [ "$shell" == "fish" ]; then
            sed -i '/# GoLang/d' "$shell_profile"
            sed -i '/set GOROOT/d' "$shell_profile"
            sed -i '/set GOPATH/d' "$shell_profile"
            sed -i '/set PATH $GOPATH\/bin $GOROOT\/bin $PATH/d' "$shell_profile"
            sed -i '/# GoLang/d' "$global_profile"
            sed -i '/PATH=\$PATH\:\/usr\/local\/go\/bin/d' "$global_profile"
        else
            sed -i '/# GoLang/d' "$shell_profile"
            sed -i '/export GOROOT/d' "$shell_profile"
            sed -i '/$GOROOT\/bin/d' "$shell_profile"
            sed -i '/export GOPATH/d' "$shell_profile"
            sed -i '/$GOPATH\/bin/d' "$shell_profile"
            sed -i '/# GoLang/d' "$global_profile"
            sed -i '/PATH=\$PATH\:\/usr\/local\/go\/bin/d' "$global_profile"
        fi
    fi
    echo "Go removed."
    exit 0
elif [ "$1" == "--help" ]; then
    print_help
    exit 0
elif [ "$1" == "--version" ]; then
    if [ -z "$2" ]; then # Check if --version has a second positional parameter
        echo "Please provide a version number for: $1"
    else
        VERSION=$2
    fi
elif [ ! -z "$1" ]; then
    echo "Unrecognized option: $1"
    exit 1
fi

if [ -d "$GOROOT" ]; then
    echo "The Go install directory ($GOROOT) already exists. Exiting."
    exit 1
fi

PACKAGE_NAME="go$VERSION.$PLATFORM.tar.gz"
TEMP_DIRECTORY=$(mktemp -d)

echo "Downloading $PACKAGE_NAME ..."
if hash wget 2>/dev/null; then
    wget https://storage.googleapis.com/golang/$PACKAGE_NAME -O "$TEMP_DIRECTORY/go.tar.gz"
else
    curl -o "$TEMP_DIRECTORY/go.tar.gz" https://storage.googleapis.com/golang/$PACKAGE_NAME
fi

if [ $? -ne 0 ]; then
    echo "Download failed! Exiting."
    exit 1
fi

echo "Extracting File..."
sudo mkdir -p -m 755 "$GOROOT"
sudo tar -C "$GOROOT" --strip-components=1 -xzf "$TEMP_DIRECTORY/go.tar.gz"

echo "Configuring shell profile in: $shell_profile"
touch "$shell_profile"
if [ "$shell" == "fish" ]; then
    {
        echo '# GoLang'
        echo "set GOROOT '${GOROOT}'"
        echo "set GOPATH '$GOPATH'"
        echo 'set PATH $GOPATH/bin $GOROOT/bin $PATH'
    } >> "$shell_profile"
else
    {
        echo '# GoLang'
        echo "export GOROOT=${GOROOT}"
        echo 'export PATH=$GOROOT/bin:$PATH'
        echo "export GOPATH=$GOPATH"
        echo 'export PATH=$GOPATH/bin:$PATH'
    } >> "$shell_profile"
fi

echo "export environment variables..."
# export environment variables global 
sudo bash -c "cat >> /etc/profile" << EOL
# GoLang
export PATH=\$PATH:/usr/local/go/bin
EOL

#source 
source $global_profile
source $shell_profile
sleep 5s

# mkdir ${GOPATH}/"{src,pkg,bin}
mkdir -p "${GOPATH}/"{src,pkg,bin} || true 

# rm tmp dir 
sudo rm -f "$TEMP_DIRECTORY/go.tar.gz"

# done 
echo -e "\nGo $VERSION was installed into $GOROOT.\nMake sure to relogin into your shell or run:"
echo -e "\n\tsource $shell_profile\n\nto update your environment variables."
echo -e "Tip: Opening a new terminal window usually just works. :)"
echo "golang INSTALLATION in ${DIR} - DONE❗" 
exit 0
```