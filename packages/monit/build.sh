TERMUX_PKG_HOMEPAGE=https://mmonit.com/monit/
TERMUX_PKG_DESCRIPTION="Utility for managing and monitoring processes, programs, files, directories and filesystems"
TERMUX_PKG_LICENSE="AGPL-V3"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="6.0.0"
TERMUX_PKG_SRCURL="https://mmonit.com/monit/dist/monit-${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="ddacd2a8120aeb2351e4486ee04a17782b5004aee99f2041d829bc4dcf2a5b3b"
TERMUX_PKG_DEPENDS="libandroid-glob, libandroid-support, zlib, openssl, libcrypt"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--without-pam
--with-ssl=yes
--with-ssl-dir=$TERMUX_PREFIX
--with-ssl-incl-dir=$TERMUX_PREFIX/include
--with-ssl-lib-dir=$TERMUX_PREFIX/lib
--oldincludedir=$TERMUX_PREFIX/include
--enable-optimized
LIBS=-landroid-glob
"
TERMUX_PKG_EXTRA_LDFLAGS="-L$TERMUX_PREFIX/lib"

termux_step_pre_configure() {
	export CPPFLAGS="-I$TERMUX_PREFIX/include $CPPFLAGS"
	export LDFLAGS="-L$TERMUX_PREFIX/lib $LDFLAGS"
	export LIBS="-lssl -lcrypto"
}

termux_step_configure() {
	"$TERMUX_PKG_SRCDIR/bootstrap"
	"$TERMUX_PKG_SRCDIR/configure" \
		--host="$TERMUX_HOST_PLATFORM" \
		--prefix="$TERMUX_PREFIX" \
		--sysconfdir="$TERMUX_PREFIX/etc" \
		$TERMUX_PKG_EXTRA_CONFIGURE_ARGS
}
