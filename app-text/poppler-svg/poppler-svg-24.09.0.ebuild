# Copyright 2005-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic toolchain-funcs xdg-utils

inherit git-r3
EGIT_REPO_URI="https://github.com/vivo75/poppler.git"
EGIT_COMMIT="f53013960ffc618b9416db32db6f8fa5bc9fe3e3"
SLOT="0/9999"

DESCRIPTION="Fork of poppler for pdftosvg support"
HOMEPAGE="https://poppler.freedesktop.org/"

LICENSE="GPL-2"
IUSE="boost cairo cjk curl +cxx debug doc gpgme +introspection +jpeg +jpeg2k +lcms nss png qt5 qt6 test tiff +utils"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=media-libs/fontconfig-2.13
	>=media-libs/freetype-2.10
	sys-libs/zlib
	cairo? (
		>=dev-libs/glib-2.64:2
		>=x11-libs/cairo-1.16
		introspection? ( >=dev-libs/gobject-introspection-1.72:= )
	)
	curl? ( net-misc/curl )
	gpgme? ( >=app-crypt/gpgme-1.19.0:=[cxx] )
	jpeg? ( >=media-libs/libjpeg-turbo-1.1.0:= )
	jpeg2k? ( >=media-libs/openjpeg-2.3.0-r1:2= )
	lcms? ( media-libs/lcms:2 )
	nss? ( >=dev-libs/nss-3.49 )
	png? ( media-libs/libpng:0= )
	qt5? (
		>=dev-qt/qtcore-5.15.2:5
		>=dev-qt/qtgui-5.15.2:5
		>=dev-qt/qtxml-5.15.2:5
	)
	qt6? ( dev-qt/qtbase:6[gui,xml] )
	tiff? ( media-libs/tiff:= )
"
RDEPEND="${COMMON_DEPEND}
	cjk? ( app-text/poppler-data )
"
DEPEND="${COMMON_DEPEND}
	boost? ( >=dev-libs/boost-1.74 )
	test? (
		qt5? (
			>=dev-qt/qttest-5.15.2:5
			>=dev-qt/qtwidgets-5.15.2:5
		)
		qt6? ( dev-qt/qtbase:6[widgets] )
	)
"
BDEPEND="
	>=dev-util/glib-utils-2.64
	virtual/pkgconfig
"

DOCS=( AUTHORS NEWS README.md README-XPDF )

PATCHES=(
	"${FILESDIR}/${PN%-svg}-23.10.0-qt-deps.patch"
	"${FILESDIR}/${PN%-svg}-21.09.0-respect-cflags.patch"
	"${FILESDIR}/${PN%-svg}-0.57.0-disable-internal-jpx.patch"
)

src_unpack() {
	git-r3_src_unpack

	default
}

src_prepare() {
	cmake_src_prepare

	# Clang doesn't grok this flag, the configure nicely tests that, but
	# cmake just uses it, so remove it if we use clang
	if tc-is-clang ; then
		sed -e 's/-fno-check-new//' -i cmake/modules/PopplerMacros.cmake || die
	fi

	if ! grep -Fq 'cmake_policy(SET CMP0002 OLD)' CMakeLists.txt ; then
		sed -e '/^cmake_minimum_required/acmake_policy(SET CMP0002 OLD)' \
			-i CMakeLists.txt || die
	else
		einfo "policy(SET CMP0002 OLD) - workaround can be removed"
	fi
}

src_configure() {
	xdg_environment_reset
	append-lfs-flags # bug #898506

	local mycmakeargs=(
		-DBUILD_GTK_TESTS=OFF
		-DBUILD_QT5_TESTS=$(usex test $(usex qt5))
		-DBUILD_QT6_TESTS=$(usex test $(usex qt6))
		-DBUILD_CPP_TESTS=$(usex test)
		-DBUILD_MANUAL_TESTS=$(usex test)
		-DTESTDATADIR="${WORKDIR}"/test-${TEST_COMMIT}
		-DRUN_GPERF_IF_PRESENT=OFF
		-DENABLE_BOOST="$(usex boost)"
		-DENABLE_ZLIB_UNCOMPRESS=OFF
		-DENABLE_UNSTABLE_API_ABI_HEADERS=ON
		-DUSE_FLOAT=OFF
		-DWITH_Cairo=$(usex cairo)
		-DENABLE_LIBCURL=$(usex curl)
		-DENABLE_CPP=$(usex cxx)
		-DENABLE_GPGME=$(usex gpgme)
		-DWITH_JPEG=$(usex jpeg)
		-DENABLE_DCTDECODER=$(usex jpeg libjpeg none)
		-DENABLE_LIBOPENJPEG=$(usex jpeg2k openjpeg2 none)
		-DENABLE_LCMS=$(usex lcms)
		-DENABLE_NSS3=$(usex nss)
		-DWITH_PNG=$(usex png)
		-DENABLE_QT5=$(usex qt5)
		-DENABLE_QT6=$(usex qt6)
		-DENABLE_LIBTIFF=$(usex tiff)
		-DENABLE_UTILS=$(usex utils)
	)
	use cairo && mycmakeargs+=( -DWITH_GObjectIntrospection=$(usex introspection) )

	cmake_src_configure
}

src_install() {
	cmake_src_install

	# live version doesn't provide html documentation
}
