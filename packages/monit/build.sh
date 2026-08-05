TERMUX_PKG_HOMEPAGE=https://mmonit.com/monit/
TERMUX_PKG_DESCRIPTION="Utility for managing and monitoring processes, programs, files, directories and filesystems"
TERMUX_PKG_LICENSE="AGPL-3.0"
TERMUX_PKG_LICENSE_FILE="COPYING"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="5.33.0"
TERMUX_PKG_SRCURL=https://mmonit.com/monit/dist/monit-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=SKIP_CHECKSUM
TERMUX_PKG_DEPENDS="libandroid-support, zlib, openssl"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--without-pam
--with-ssl=enabled
--with-ssl-dir=$TERMUX_PREFIX
--with-ssl-incl-dir=$TERMUX_PREFIX/include
--with-ssl-lib-dir=$TERMUX_PREFIX/lib
--enable-optimized
"

termux_step_pre_configure() {
	export CPPFLAGS="-I$TERMUX_PREFIX/include $CPPFLAGS"
	export LDFLAGS="-L$TERMUX_PREFIX/lib $LDFLAGS"
	export LIBS="-lssl -lcrypto"
}

termux_step_configure() {
	"$TERMUX_PKG_SRCDIR/configure" \
		--host=$TERMUX_HOST_PLATFORM \
		--prefix=$TERMUX_PREFIX \
		--sysconfdir=$TERMUX_PREFIX/etc \
		$TERMUX_PKG_EXTRA_CONFIGURE_ARGS 2> >(grep -v "tput: unknown terminfo capability" >&2)

	# Ensure HAVE_SSL is strictly enabled across generated configurations
	for cfg in $(find . -name "config.h" -o -name "Config.h" -o -name "libmonit.h"); do
		if [ -f "$cfg" ]; then
			sed -i 's/#undef HAVE_SSL/#define HAVE_SSL 1/g' "$cfg"
			sed -i 's/#define HAVE_SSL 0/#define HAVE_SSL 1/g' "$cfg"
		fi
	done
}
