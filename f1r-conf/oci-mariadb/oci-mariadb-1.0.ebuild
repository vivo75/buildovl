# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd s6 tmpfiles

DESCRIPTION="Gentoo MySQL init scripts"
HOMEPAGE="https://wiki.gentoo.org/wiki/No_homepage"
# Need to set S due to PMS saying we need it existing, but no SRC_URI
S=${WORKDIR}

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ~loong ~mips ppc ppc64 ~riscv ~s390 sparc x86"

# mysql-connector-c needed for my_print_defaults
RDEPEND="
	!<dev-db/mysql-5.1
	dev-db/mysql-connector-c
	!prefix? (
		acct-group/mysql acct-user/mysql
	)
"

src_install() {
	insinto /etc/mysql/mariadb.d
	newins "${FILESDIR}"/distro-server-001.cnf 50-distro-server.cnf

	exeinto /usr/bin
	newexe "${FILESDIR}"/docker-entrypoint-001.sh docker-entrypoint.sh
	newexe "${FILESDIR}"/healthcheck-001.sh healthcheck.sh

	mkdir -p "${S}"/docker-entrypoint-initdb.d
	#mkdir -p /var/lib/mysql /run/mysqld
	#chown -R mysql:mysql /var/lib/mysql /run/mysqld
	#chmod 1777 /run/mysqld
}

pkg_postinst() {
	tmpfiles_process mysql.conf

	if use amd64 || use x86 ; then
		elog "To use the mysql-s6 script, you need to install the optional sys-apps/s6 package."
		elog "If you wish to use s6 logging support, comment out the log-error setting in your my.cnf"
		elog
	fi

	elog "Starting with version 10.1.8, MariaDB includes an improved systemd unit named mariadb.service"
	elog "You should prefer that unit over this package's mysqld.service."
}
