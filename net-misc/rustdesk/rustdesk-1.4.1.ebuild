# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit desktop xdg unpacker

DESCRIPTION="Open source virtual / remote desktop infrastructure for everyone!"
HOMEPAGE="https://rustdesk.com/"
SRC_URI="https://github.com/rustdesk/rustdesk/releases/download/${PV}/rustdesk-${PV}-x86_64.deb -> ${P}.deb"

LICENSE=""
SLOT="0"
KEYWORDS="amd64"

RDEPEND="
	x11-libs/libxcb
	x11-libs/gtk+:3
	x11-misc/xdotool
	x11-libs/libXfixes
	media-sound/pulseaudio
	dev-lang/python
	net-misc/curl
"
S=${WORKDIR}
MY_P="rustdesk"
OPT="usr/${MY_P}"

src_unpack() {
	unpack_deb ${A}
}

src_install() {
	cp -R usr "${D}"
}

pkg_postinst() {
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
}

