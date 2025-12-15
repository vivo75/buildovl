# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

KERNEL_IUSE_GENERIC_UKI=1
KERNEL_IUSE_MODULES_SIGN=1
KERNEL_GENERIC_UKI_CMDLINE='root=LABEL=gentooroot ro console=ttyS0 console=tty0 init=/lib/systemd/systemd consoleblank=0 net.ifnames=0 nomodeset systemd.show_status=true'
# SECUREBOOT_SIGN_KEY="${SECUREBOOT_SIGN_KEY:-/etc/ssl/private/secure_boot/db.key}"
# SECUREBOOT_SIGN_CERT="${SECUREBOOT_SIGN_CERT:-/etc/ssl/private/secure_boot/db.crt}"
# sbctl create-keys
# /var/lib/sbctl/keys/db/*

inherit kernel-build toolchain-funcs verify-sig

BASE_P=linux-${PV%.*}
# https://koji.fedoraproject.org/koji/packageinfo?packageID=8
# forked to https://github.com/projg2/fedora-kernel-config-for-gentoo
CONFIG_VER=6.18 # => kernel-x86_64-fedora.config.${CONFIG_VER}
SHA256SUM_DATE=20251212

DESCRIPTION="Linux kernel built from vanilla upstream sources"
HOMEPAGE="
	https://wiki.gentoo.org/wiki/Project:Distribution_Kernel
	https://www.kernel.org/
"
SRC_URI+="
	https://cdn.kernel.org/pub/linux/kernel/v$(ver_cut 1).x/${BASE_P}.tar.xz
	https://cdn.kernel.org/pub/linux/kernel/v$(ver_cut 1).x/patch-${PV}.xz
	verify-sig? (
		https://cdn.kernel.org/pub/linux/kernel/v$(ver_cut 1).x/sha256sums.asc
			-> linux-$(ver_cut 1).x-sha256sums-${SHA256SUM_DATE}.asc
	)
"
S=${WORKDIR}/${BASE_P}
KBUILD_OUTPUT=

KEYWORDS="amd64"
IUSE="debug hardened tools_hyperv"
# REQUIRED_USE="
# 	amd64? ( savedconfig )
# "

BDEPEND="
	debug? ( dev-util/pahole )
	verify-sig? ( >=sec-keys/openpgp-keys-kernel-20250702 )
"
#PDEPEND="
#	>=virtual/dist-kernel-${PV}
#"

VERIFY_SIG_OPENPGP_KEY_PATH=/usr/share/openpgp-keys/kernel.org.asc

QA_FLAGS_IGNORED="
	usr/src/linux-.*/scripts/gcc-plugins/.*.so
	usr/src/linux-.*/vmlinux
	usr/src/linux-.*/arch/powerpc/kernel/vdso.*/vdso.*.so.dbg
"

src_unpack() {
	if use verify-sig; then
		cd "${DISTDIR}" || die
		verify-sig_verify_signed_checksums \
			"linux-$(ver_cut 1).x-sha256sums-${SHA256SUM_DATE}.asc" \
			sha256 "${BASE_P}.tar.xz patch-${PV}.xz"
		cd "${WORKDIR}" || die
	fi

	default
}

src_prepare() {
	eapply "${WORKDIR}/patch-${PV}"
	default

	# prepare the default config
	case ${ARCH} in
		amd64)
			cp "${FILESDIR}/${PV%.*}.config" .config || die
			;;
		*)
			die "Unsupported arch ${ARCH}"
			;;
	esac

	local myversion="-csp"
	use hardened && myversion+="-hardened"
	echo "CONFIG_LOCALVERSION=\"${myversion}\"" > "${T}"/version.config || die
	local dist_conf_path="${FILESDIR}/extra-${PV%.*}"

	local merge_configs=(
		"${T}"/version.config
	)
	use debug || merge_configs+=(
		"${dist_conf_path}"/no-debug.config
	)
	if use hardened; then
		merge_configs+=( "${dist_conf_path}"/hardened-base.config )

		tc-is-gcc && merge_configs+=( "${dist_conf_path}"/hardened-gcc-plugins.config )

		if [[ -f "${dist_conf_path}/hardened-${ARCH}.config" ]]; then
			merge_configs+=( "${dist_conf_path}/hardened-${ARCH}.config" )
		fi
	fi

	use secureboot && merge_configs+=(
		"${dist_conf_path}/secureboot.config"
		"${dist_conf_path}/zboot.config"
	)

	# Prepare Hyperv tools
	sed -i -e 's/hv_set_ifconfig.sh//' "${S}"/tools/hv/Makefile || die
	cp -vf "${FILESDIR}"/usr-libexec-hypervkvpd-hv_get_dhcp_info "${S}"/tools/hv/hv_get_dhcp_info.sh
	cp -vf "${FILESDIR}"/usr-libexec-hypervkvpd-hv_get_dns_info "${S}"/tools/hv/hv_get_dns_info.sh
	
	echo "Adding configs: ${merge_configs[@]}"
	kernel-build_merge_configs "${merge_configs[@]}"
}

src_compile() {
	kernel-build_src_compile
	
	if use tools_hyperv; then
		echo "Building Hyperv tools used in Azure and Windows virtualization"
		pushd "${S}"/tools/hv > /dev/null || die
			emake DESTDIR="${ED}"/
		popd > /dev/null
	fi
}

src_install() {
	if use tools_hyperv; then
		pushd "${S}"/tools/hv > /dev/null || die
		emake O="${WORKDIR}"/build "${MAKEARGS[@]}" DESTDIR="${ED}" install
		popd > /dev/null
	fi

	kernel-build_src_install
}
