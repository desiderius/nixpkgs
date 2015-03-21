{ stdenv, fetchurl, autoconf, automake, libtool, pkgconfig
, glib, pam
, icu
, libdnet
, procps-old
}:

stdenv.mkDerivation rec {

  name = "open-vm-tools";
  version = "9.4.6-1770165";

  src = fetchurl {
    url = "http://sourceforge.net/projects/open-vm-tools/files/open-vm-tools/stable-9.4.x/${name}-${version}.tar.gz";
    sha256 = "0yd0cjh8bg5drl2z3hh1i2151fhpf26v164hh15lw4hmh4ysimsl";
  };

  buildInputs = [ stdenv autoconf automake libtool pkgconfig glib pam icu libdnet procps-old ];

  preConfigure = ''
    substituteInPlace lib/guestApp/guestApp.c --replace /etc/vmware-tools $out/etc/vmware-tools
    substituteInPlace lib/misc/codeset.c --replace /etc/vmware-tools $out/etc/vmware-tools
    substituteInPlace scripts/Makefile.am --replace /etc/vmware-tools $out/etc/vmware-tools
    substituteInPlace services/vmtoolsd/Makefile.am --replace "\$(DESTDIR)/etc/vmware-tools" $out/etc/vmware-tools
    autoreconf -i
  '';

  configureFlags = [
    "--localstatedir=/var"
    "--disable-dependency-tracking"
    "--disable-multimon"
    "--disable-docs"
    "--without-kernel-modules"
    "--with-x=no"
    "--without-gtk2"
    "--without-gtkmm"
    "--without-procps"
  ];

#    "--without-icu"
#    "--without-dnet"

  NIX_CFLAGS_COMPILE="-Ilib/include -D_DEFAULT_SOURCE -Wno-deprecated-declarations -Wno-sizeof-pointer-memaccess";

  patches = [ ./0002-conditionaly-define-g_info-macro.patch
            ];

  patchFlags = "-p2";

  enableParallelBuilding = true;
}
