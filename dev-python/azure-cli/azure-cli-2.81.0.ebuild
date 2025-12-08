# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{13..14} )
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="Multi-platform command line experience for Azure"
HOMEPAGE="https://github.com/Azure/azure-cli https://pypi.org/project/azure-cli/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="" # Does not work

RDEPEND="dev-python/pip
		virtual/libcrypt
"
BDEPEND="${RDEPEND}"
RESTRICT="test" # no time for that ATM

src_install() {
	distutils-r1_src_install
	rm -r "${ED}"/usr/bin/{az.bat,azps.ps1}
}
