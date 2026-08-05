TERMUX_PKG_HOMEPAGE=https://mmonit.com/monit/
TERMUX_PKG_DESCRIPTION="Utility for managing and monitoring processes, programs, files, directories and filesystems"
TERMUX_PKG_LICENSE="AGPL-3.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="5.33.0"
TERMUX_PKG_SRCURL=https://mmonit.com/monit/dist/monit-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=SKIP_CHECKSUM
TERMUX_PKG_DEPENDS="libandroid-support, zlib, openssl"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--without-pam
--with-ssl=enabled
--with-ssl-dir=$TERMUX_PREFIX
--with-ssl-incl-dir=$TERMUX_PREFIX/include
--with-ssl-lib-dir=$TERMUX_PREFIX/lib
--enable-optimized
"

termux_step_pre_configure() {
	# Fix getdtablesize() for Android Bionic
	sed -i 's/fileDescriptors = getdtablesize();/fileDescriptors = sysconf(_SC_OPEN_MAX);/g' libmonit/src/system/System.c

	# Ensure the build directory's src structure exists and create Ssl.h there for out-of-tree builds
	mkdir -p "$TERMUX_PKG_BUILDDIR/src"
	cat << 'EOF' > "$TERMUX_PKG_BUILDDIR/src/Ssl.h"
#ifndef _MONIT_SSL_H
#define _MONIT_SSL_H
#include "net/ssl.h"
#endif
EOF

	export CPPFLAGS="-I$TERMUX_PREFIX/include $CPPFLAGS"
	export LDFLAGS="-L$TERMUX_PREFIX/lib $LDFLAGS"
	export LIBS="-lssl -lcrypto"

	export CFLAGS="$CFLAGS -I$TERMUX_PKG_SRCDIR/src -I$TERMUX_PKG_BUILDDIR -I$TERMUX_PKG_BUILDDIR/src \
-I$TERMUX_PKG_SRCDIR/src/device -I$TERMUX_PKG_SRCDIR/src/protocols \
-I$TERMUX_PKG_SRCDIR/libmonit/src -I$TERMUX_PKG_BUILDDIR/libmonit/src \
-I$TERMUX_PKG_SRCDIR/libmonit/src/exceptions -I$TERMUX_PKG_SRCDIR/libmonit/src/io \
-I$TERMUX_PKG_SRCDIR/libmonit/src/net -I$TERMUX_PKG_SRCDIR/libmonit/src/util \
-I$TERMUX_PKG_SRCDIR/libmonit/src/thread -I$TERMUX_PKG_SRCDIR/libmonit/src/system"
}

termux_step_configure() {
	"$TERMUX_PKG_SRCDIR/configure" \
		--host=$TERMUX_HOST_PLATFORM \
		--prefix=$TERMUX_PREFIX \
		--sysconfdir=$TERMUX_PREFIX/etc \
		$TERMUX_PKG_EXTRA_CONFIGURE_ARGS 2> >(grep -v "tput: unknown terminfo capability" >&2)

	# Ensure HAVE_SSL is strictly enabled across all generated configurations
	for cfg in $(find . -name "config.h" -o -name "Config.h" -o -name "libmonit.h"); do
		if [ -f "$cfg" ]; then
			sed -i 's/#undef HAVE_SSL/#define HAVE_SSL 1/g' "$cfg"
			sed -i 's/#define HAVE_SSL 0/#define HAVE_SSL 1/g' "$cfg"
		fi
	done
}
