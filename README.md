# Setup
In order to setup the environment, run the following command and everything will
be set-up for you.

```
wget -O - https://raw.githubusercontent.com/rranelli/linuxsetup/master/bootstrap.sh | bash -s
```


# Dump dconf
```sh
dconf dump / > $(find . -name *dconf*)
```

# Load dconf
```sh
dconf load / < $(find . -name *dconf*)
```
