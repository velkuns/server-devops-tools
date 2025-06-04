# server-devops-tools
The purpose of this tool is to have simples `make` commands to install PHP / MariaDB / Apache on a Debian/Ubuntu based 
system.

## Requirements
You must have the following tools / package installed on your system (Debian/Ubuntu based systems):
- git
- lsb_release
- make

## Installation
```shell
git clone https://github.com/velkuns/server-devops-tools
```


## Usage
Before using the tool, you must choose the version of PHP you want to install. 
You can do this by editing the `Makefile` and setting the `PHP_VERSION` variable to the desired version 
(e.g., `7.4`, `8.0`, etc.).

Do the same for the `MARIADB_VERSION` variable to set the desired version of MariaDB.

Then you can run make commands to install the desired software.

### Commands

#### Display environment configuration
```shell
make display-config
```

#### Install full server stack (update & upgrade system + install PHP, MariaDB, Apache2)
```shell
make install-server
```

#### Install AMP stack (Apache, MariaDB, PHP)
```shell
make install-lamp
```

#### Install only PHP
```shell
make install-php
```

#### Install only MariaDB
```shell
make install-mariadb
```

#### Install only Apache2
```shell
make install-apache2
```

#### Install PHP Switch
When you need to switch between different PHP versions, you can use the `install-php-switch` command to install 
utilities that allow you to easily switch between installed PHP versions.

But you need to install other PHP versions first, by editing Makefile & using the `make install-php` command.
```shell
make install-php-switch
```

Then, when switching utilities are installed, you can switch between PHP versions using the following command:
```shell
use-php74
```
```shell
use-php81
```
```shell
use-php82
```
```shell
use-php83
```
```shell
use-php84
```
