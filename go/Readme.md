# GoLang

Download and install Go quickly with the `goBinaryInstall.sh` bash script provided in this repository. 

## Notes 
**Remove any previous Go installation** by deleting the /usr/local/go folder (if it exists). 
For a system-wide installation we add `export PATH=$PATH:/usr/local/go/bin` to `/etc/profile` and some more environment variables to `$HOME/.bashrc`.

**Some command explantion** 
```
#specify Go version 
sh goBinaryInstall.sh --version 1.18.3

#remove Go 
sh goBinaryInstall.sh --remove

#Verify Go version
go version

# Verify Go environment 
go env
```

## Resources 
- [go.dev](https://go.dev/doc/install)
- [Setting Up Your Go Environment](https://www.oreilly.com/library/view/learning-go/9781492077206/ch01.html)
- [How To Install Go on Ubuntu 20.04](https://www.digitalocean.com/community/tutorials/how-to-install-go-on-ubuntu-20-04)
- [Video - Setting up your Go Environment and Golang Workspace](https://www.oreilly.com/library/view/the-complete-google/9781788626972/video2_3.html)
- [command 'go' not found](https://askubuntu.com/questions/1092589/command-go-not-found)
- [How to permanently set GOPATH environmental variable](https://stackoverflow.com/questions/56557645/how-to-permanently-set-gopath-environmental-variable)

