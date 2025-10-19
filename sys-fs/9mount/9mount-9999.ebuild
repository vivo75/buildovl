# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A set of SUID mounting tools for use with v9fs."
HOMEPAGE="http://github.com/minad/9mount"
EGIT_REPO_URI="https://github.com/minad/9mount.git"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

inherit git-r3

src_install() {
	dobin 9mount 9umount 9bind
	fperms 4755 /usr/bin/{9mount,9umount,9bind}
}

