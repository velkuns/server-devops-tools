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
- Default version of PHP is:     `8.5`
- Default version of MariaDB is: `12.2`

You can change the default versions of PHP and MariaDB in the `Makefile` file, by adding after the make command:
- for PHP: `PHP_VERSION=X.Y`
- for MariaDB: `MARIADB_VERSION=X.Y`

Default php extension installed: `common cli mbstring`.
To add more extension, you can specify them via `php_ext="curl memcached mysql xml xdebug zip"`

Example:
```shell
make install-server PHP_VERSION=8.5 MARIADB_VERSION=11.7 php_ext="curl mysql xdebug zip"
```

### Commands

#### Display environment configuration
```shell
make display-config
```

If you need to install specific versions of PHP and MariaDB, you can specify them as follows:
```shell
make display-config PHP_VERSION=8.3 MARIADB_VERSION=11.7 php_ext="curl mysql xdebug zip"
```

#### Install full server stack (update & upgrade system + install PHP, MariaDB, Apache2)
```shell
make install-server
```

If you need to install specific versions of PHP and MariaDB, you can specify them as follows:
```shell
make install-server PHP_VERSION=8.3 MARIADB_VERSION=11.7
```

#### Install AMP stack (Apache, MariaDB, PHP)
```shell
make install-lamp
```

#### Install only PHP
```shell
make install-php-cli
```

#### Install only PHP + apache2 mod
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
