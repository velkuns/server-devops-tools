.PHONY: install install-commands install-server

PHP_VERSION := 8.3
MARIADB_VERSION := 10.9
OS_TYPE := $(shell lsb_release -si || echo "debian")
OS_DIST := $(shell lsb_release -sc || echo "bullseye")
SHELL_TYPE := zsh

define header =
    @if [ -t 1 ]; then printf "\n\e[37m\e[100m  \e[104m $(1) \e[0m\n"; else printf "\n### $(1)\n"; fi
endef

display-config:
	$(call header,Show Config)
	@echo "  . os type: ${OS_TYPE}"
	@echo "  . os dist: ${OS_DIST}"

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
	@sudo apt install -y wget lsb-release gnupg2 software-properties-common dirmngr ca-certificates apt-transport-https debian-keyring

install-server: server-install-header server-update server-upgrade install-lamp

install-lamp: clean-php install-mariadb install-php install-apache2

install-mariadb: install-cert-tool
	$(call header,Install MariaDB)
	@echo " . Get & save last signing key"
	@sudo wget -O- https://mariadb.org/mariadb_release_signing_key.asc | gpg --dearmor | sudo tee /usr/share/keyrings/mariadb.gpg
	@echo " . Updating source.list (mariadb.list)"
	@echo "deb [arch=amd64,arm64,ppc64el signed-by=/usr/share/keyrings/mariadb.gpg] http://mirror.mariadb.org/repo/${MARIADB_VERSION}/${OS_TYPE}/ ${OS_DIST} main" | sudo tee /etc/apt/sources.list.d/mariadb.list
	@echo " . Apt list update"
	@sudo apt update && sudo apt upgrade -y
	@echo " . Installing mariadb-server"
	@sudo apt install mariadb-server
	@echo " . Securing the installation"
	@sudo mysql_secure_installation
	@echo " . Adding 'admin' account in mysql"
	@echo "  => GRANT ALL ON *.* TO 'admin'@'localhost' IDENTIFIED BY 'password' WITH GRANT OPTION;"
	@echo "  => FLUSH PRIVILEGES;"
	@echo "  => exit"
	@sudo mysql

clean-php:
	@echo "Remove previous bundled os php version"
	@sudo apt remove --purge php*

install-php: install-cert-tool
	$(call header,Install PHP)
	@echo " . Get & save last signing key"
	@sudo wget -qO - https://packages.sury.org/php/apt.gpg | sudo gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/debian-php-8.gpg --import
	@echo " . Updating source.list (sury-php.list)"
	@echo "deb https://packages.sury.org/php/ ${OS_DIST} main" | sudo tee /etc/apt/sources.list.d/sury-php.list
	@echo " . Apt list update"
	@sudo apt update && sudo apt upgrade -y
	@echo " . Installing PHP ${PHP_VERSION}"
	@sudo apt install -y \
		php${PHP_VERSION}-common \
		php${PHP_VERSION}-cli \
		php${PHP_VERSION}-curl \
		php${PHP_VERSION}-mbstring \
		php${PHP_VERSION}-memcache \
		php${PHP_VERSION}-mysql

install-apache2:
	$(call header,Install Apache2)
	@sudo apt install -y \
		apache2 \
		libapache2-mod-php${PHP_VERSION}
	@sudo a2enmod rewrite && a2enmod headers
