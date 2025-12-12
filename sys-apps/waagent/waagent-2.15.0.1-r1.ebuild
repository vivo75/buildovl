# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{13..14} )
DISTUTILS_SINGLE_IMPL=1
inherit distutils-r1 systemd

DESCRIPTION="Microsoft Azure Linux Agent"
HOMEPAGE="https://github.com/Azure/WALinuxAgent"
SRC_URI="https://github.com/Azure/WALinuxAgent/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64"

RDEPEND=">=dev-libs/openssl-1.0.1h-r2
		>=net-misc/openssh-6.6_p1-r1
		sys-apps/iproute2
		dev-python/crypt-r
		dev-python/pyasn1-modules"
BDEPEND="${RDEPEND}"

DOCS=( MAINTENANCE.md README.md )

RESTRICT="test" # no time for that ATM

python_prepare_all() {
	distutils-r1_python_prepare_all
}

S="${WORKDIR}/WALinuxAgent-${PV}"

src_install() {
	local sitedir=${D}$(python_get_sitedir)

	distutils-r1_src_install

	insinto /etc
	doins "${FILESDIR}"/waagent.conf

	insinto /usr/lib/udev/rules.d
	doins "${sitedir}"/etc/udev/rules.d/*.rules

	systemd_dounit "${FILESDIR}"/walinuxagent.service

	insinto /etc/logrotate.d
	newins "${FILESDIR}"/waagent.logrotate waagent

	#dosbin "${sitedir}"/usr/sbin/waagent
	#dosbin "${sitedir}"/usr/sbin/waagent2.0
	python_scriptinto /usr/sbin
	python_doexe "${sitedir}"/usr/sbin/waagent

	rm -r "${ED}"/usr/lib/python3.13/site-packages/{etc,usr}
}
