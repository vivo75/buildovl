# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit unpacker

DESCRIPTION="Additional configuration for a VM running in HyperV (Azure)"
HOMEPAGE="https://kernel.org"
SRC_URI="
amd64? (
    https://tbz.f1r.eu/kvm/kernel-${PV}-kvm.tar
    https://tbz.f1r.eu/kvm/azure-${PV}-kvm.tar.zst -> azure-${PV}-kvm.tar.zstd
)
"
S="${WORKDIR}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

src_unpack() {
    unpacker kernel-${PV}-kvm.tar
    unpacker azure-${PV}-kvm.tar.zstd
    rm -fv "${S}"/usr/libexec/hypervkvpd/hv_set_ifconfig
}

src_install() {
    # Don't do this, it's ugly!
    cp -a "${S}"/{boot,lib,usr}/ "${ED}/" || die
    exeinto /usr/bin
    doexe "${WORKDIR}"/usr/sbin/*
    rm -rv "${ED}"/usr/sbin || die
    mv "${ED}"/boot/vmlinuz{-${PV}-kvm,} || die
    mv "${ED}"/boot/initrd{-${PV}-kvm,} || die

    insinto /boot/grub
    newins "${FILESDIR}"/boot-grub-grub.cfg grub.cfg

    exeinto /usr/libexec/hypervkvpd
    newexe "${FILESDIR}"/usr-libexec-hypervkvpd-hv_get_dhcp_info hv_get_dhcp_info
    newexe "${FILESDIR}"/usr-libexec-hypervkvpd-hv_get_dns_info hv_get_dns_info

    insinto /etc/cloud/cloud.cfg.d
    doins -r "${FILESDIR}"/cloud-init/
}
