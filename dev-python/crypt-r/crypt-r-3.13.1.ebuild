# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{13..14} )
DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
inherit distutils-r1 pypi

DESCRIPTION="The crypt_r module is a renamed copy of the crypt module as it was present in Python 3.12 before it was removed"
HOMEPAGE="https://pypi.org/project/crypt-r/"

LICENSE="PYTHON"
SLOT="0"
KEYWORDS="amd64"

RDEPEND="virtual/libcrypt"
BDEPEND="${RDEPEND}"
RESTRICT="test" # no time for that ATM
