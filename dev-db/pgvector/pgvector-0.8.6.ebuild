# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

POSTGRES_COMPAT=( {16..18} )
POSTGRES_USEDEP="server"

inherit postgres-multi autotools

DESCRIPTION="Open-source vector similarity search for Postgres"
HOMEPAGE="
	https://github.com/pgvector/pgvector
"
SRC_URI="https://github.com/pgvector/pgvector/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="POSTGRESQL"

RDEPEND="
	${POSTGRES_DEP}
"


DEPEND="
	${RDEPEND}
"

SLOT="0"
KEYWORDS="~amd64"
