.PHONY: install install-commands install-server

#~ Requirements:
# - git
# - lsb_release
# - make

PHP_VERSION := 8.4
MARIADB_VERSION := 11.8
OS_TYPE := $(shell (lsb_release -si | tr '[:upper:]' '[:lower:]') || echo "debian")
OS_DIST := $(shell (lsb_release -sc | tr '[:upper:]' '[:lower:]') || echo "bullseye")
SHELL_TYPE := zsh

define header =
    @if [ -t 1 ]; then printf "\n\e[37m\e[100m  \e[104m $(1) \e[0m\n"; else printf "\n### $(1)\n"; fi
endef

display-config:
	$(call header,OS Config)
	@echo "  . os type: ${OS_TYPE}"
	@echo "  . os dist: ${OS_DIST}"
	$(call header,Software Version to install)
	@echo "  . PHP Version to Install:     ${PHP_VERSION}"
	@echo "  . MariaDB Version to Install: ${MARIADB_VERSION}"

install-php-switch:
	$(call header,Install PHP Switch commands)
	@echo " . Install use-php74"
	@sudo ln -sfn ${PWD}/php/use-php74 /usr/local/bin/use-php74
	@echo " . Install use-php81"
	@sudo ln -sfn ${PWD}/php/use-php81 /usr/local/bin/use-php81
	@echo " . Install use-php82"
	@sudo ln -sfn ${PWD}/php/use-php82 /usr/local/bin/use-php82
	@echo " . Install use-php83"
	@sudo ln -sfn ${PWD}/php/use-php83 /usr/local/bin/use-php83
	@echo " . Install use-php84"
	@sudo ln -sfn ${PWD}/php/use-php84 /usr/local/bin/use-php84
	@$(shell . ~/.${SHELL_TYPE}rc)

install-commands: install-php-switch

server-install-header:
	$(call header,Install server from scratch)

server-update:
	$(call header,Server Update)
	@sudo apt update

server-upgrade:
	$(call header,Server Upgrade)
	@sudo apt upgrade -y

install-cert-tool:
	$(call header,Install Cert Tools)
	@sudo apt install -y wget lsb-release gnupg2 software-properties-common dirmngr ca-certificates apt-transport-https debian-keyring curl
	@sudo mkdir -p /etc/apt/keyrings
	@sudo chmod 755 /etc/apt/keyrings

install-server: server-install-header clean-php clean-mariadb server-update server-upgrade install-lamp

install-lamp: clean-php clean-mariadb install-mariadb install-apache2 install-php install-done

install-mariadb: install-cert-tool
	$(call header,Install MariaDB)
	@echo " . Get & save last signing key"
	@sudo curl -o /etc/apt/keyrings/mariadb-keyring.pgp 'https://mariadb.org/mariadb_release_signing_key.pgp'
	@echo " . Updating source.list (mariadb.list)"
	@echo "deb [signed-by=/etc/apt/keyrings/mariadb-keyring.pgp] http://mariadb.mirrors.ovh.net/MariaDB/repo/${MARIADB_VERSION}/${OS_TYPE} ${OS_DIST} main" | sudo tee /etc/apt/sources.list.d/mariadb.list
	@echo " . Apt list update"
	@sudo apt update
	@echo " . Installing mariadb-server"
	@sudo apt install mariadb-server -y
	@echo " . Securing the installation"
	@sudo mysql_secure_installation
	@echo " . Adding 'admin' account in mysql"
	@echo "  => GRANT ALL ON *.* TO 'admin'@'localhost' IDENTIFIED BY 'password' WITH GRANT OPTION;"
	@echo "  => FLUSH PRIVILEGES;"
	@echo "  => exit"
	@sudo mysql

clean-php:
	@echo "Remove previous bundled os php version"
	@sudo apt remove --purge php* -y

clean-mariadb:
	@echo "Remove previous bundled os mariadb version"
	@sudo apt remove --purge mariadb-server -y

install-php: install-php-cli install-php-apache2-mod

install-php-cli:
	@if [ "${OS_TYPE}" = "debian" ]; then make install-php-debian; elif [ "${OS_TYPE}" = "ubuntu" ]; then make install-php-ubuntu; else echo "Unsupported OS type: ${OS_TYPE}"; exit 1; fi

install-php-debian: install-cert-tool
	$(call header,Install PHP)
	@echo " . Get & save last signing key"
	@sudo curl -sSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb
	@sudo dpkg -i /tmp/debsuryorg-archive-keyring.deb
	@echo " . Updating source.list (php.list)"
	@echo "deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ ${OS_DIST} main" | sudo tee /etc/apt/sources.list.d/php.list
	@echo " . Apt list update"
	@sudo apt update
	@echo " . Installing PHP ${PHP_VERSION}"
	@sudo apt install -y \
		php${PHP_VERSION}-common \
		php${PHP_VERSION}-cli \
		php${PHP_VERSION}-curl \
		php${PHP_VERSION}-dom \
		php${PHP_VERSION}-mbstring \
		php${PHP_VERSION}-memcache \
		php${PHP_VERSION}-mysql \
		php${PHP_VERSION}-xdebug \
		php${PHP_VERSION}-xml

install-php-ubuntu: install-cert-tool
	$(call header,Install PHP)
	@echo " . Updating source.list"
	@sudo LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
	@sudo apt update
	@echo " . Installing PHP ${PHP_VERSION}"
	@sudo apt install -y \
		php${PHP_VERSION}-common \
		php${PHP_VERSION}-cli \
		php${PHP_VERSION}-curl \
		php${PHP_VERSION}-dom \
		php${PHP_VERSION}-mbstring \
		php${PHP_VERSION}-memcache \
		php${PHP_VERSION}-mysql \
		php${PHP_VERSION}-xdebug \
		php${PHP_VERSION}-xml

install-apache2:
	$(call header,Install Apache2)
	@sudo apt install -y apache2
	@sudo a2enmod rewrite && sudo a2enmod headers

install-php-apache2-mod:
	$(call header,Install Apache2 Mod)
	@sudo apt install -y libapache2-mod-php${PHP_VERSION}

install-done:
	$(call header,Installation Done)
	@echo " Installation completed successfully!"
	@echo " . Installed PHP Versions:    ${PHP_VERSION}"
	@echo " . Installed MariaDB Version: ${MARIADB_VERSION}"
	@echo ""
	@echo "If you want add & install another PHP version, you can run:"
	@echo "make install-php"
	@echo "You can also run the following commands to install utilities to allow you to switch between php versions:"
	@echo "make install-php-switch"
	@echo " . Then, you can now use the following commands to switch PHP versions:"
	@echo "use-php74"
	@echo "use-php81"
	@echo "use-php82"
	@echo "use-php83"
	@echo "use-php84"
