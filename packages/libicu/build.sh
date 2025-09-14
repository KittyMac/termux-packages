TERMUX_PKG_HOMEPAGE=http://site.icu-project.org/home
TERMUX_PKG_DESCRIPTION='International Components for Unicode library'
TERMUX_PKG_LICENSE="custom"
# We override TERMUX_PKG_SRCDIR termux_step_post_get_source so need to do
# this hack to be able to find the license file.
TERMUX_PKG_LICENSE_FILE="../LICENSE"
TERMUX_PKG_MAINTAINER="@termux"
# Never forget to always bump revision of reverse dependencies and rebuild them
# when bumping "major" version.
TERMUX_PKG_VERSION="77.1"
TERMUX_PKG_REVISION=2
TERMUX_PKG_SRCURL=https://github.com/unicode-org/icu/releases/download/release-${TERMUX_PKG_VERSION//./-}/icu4c-${TERMUX_PKG_VERSION//./_}-src.tgz
TERMUX_PKG_SHA256=588e431f77327c39031ffbb8843c0e3bc122c211374485fa87dc5f3faff24061
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_METHOD=repology
TERMUX_PKG_DEPENDS="libc++"
TERMUX_PKG_BREAKS="libicu-dev"
TERMUX_PKG_REPLACES="libicu-dev"
TERMUX_PKG_HOSTBUILD=true
TERMUX_PKG_EXTRA_HOSTBUILD_CONFIGURE_ARGS="--disable-samples --disable-tests"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="--disable-samples --disable-tests --with-cross-build=$TERMUX_PKG_HOSTBUILD_DIR"

termux_step_post_get_source() {
	rm $TERMUX_PKG_SRCDIR/LICENSE
	curl -o $TERMUX_PKG_SRCDIR/LICENSE -L https://raw.githubusercontent.com/unicode-org/icu/release-${TERMUX_PKG_VERSION//./-}/LICENSE
	TERMUX_PKG_SRCDIR+="/source"
	find . -type f | xargs touch
    
    pushd "${TERMUX_PKG_SRCDIR}"
    rm -rf data
    curl -o data.zip -L https://github.com/unicode-org/icu/releases/download/release-77-1/icu4c-77_1-data.zip
    unzip data.zip
    popd

    # HACK TO FORCE ICU_DATA_FILTER_FILE IN THE CONFIGURATION FILE
    sed -i -e 's|\$ICU_DATA_FILTER_FILE|/home/builder/termux-packages/packages/libicu/data_filters.json|g' "${TERMUX_PKG_SRCDIR}/configure"
}

termux_step_post_massage() {
	local _GUARD_FILE="lib/libicuuc.so.77"
	if [ ! -e "${_GUARD_FILE}" ]; then
		termux_error_exit "Error: file ${_GUARD_FILE} not found."
	fi
}
