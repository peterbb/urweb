with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "urweb-${version}";
  version = "dev";

  src = ./. ;

  buildInputs = [ automake autoconf libtool openssl
         mlton mysql.client postgresql sqlite ];

  prePatch = ''
	autoreconf -fvi -I ${libtool}/share/aclocal/
    sed -e 's@/usr/bin/file@${file}/bin/file@g' -i configure
  '';

  configureFlags = "--with-openssl=${openssl.dev} --program-suffix=-dev";

  preConfigure = ''

    export PGHEADER="${postgresql}/include/libpq-fe.h";
    export MSHEADER="${lib.getDev mysql.client}/include/mysql/mysql.h";
    export SQHEADER="${sqlite.dev}/include/sqlite3.h";

    export CC="${gcc}/bin/gcc";
    export CCARGS="-I$out/include \
                   -L${openssl.out}/lib \
                   -L${lib.getLib mysql.client}/lib \
                   -L${postgresql.lib}/lib \
                   -L${sqlite.out}/lib";
  '';

  postInstall = ''
    mv $out/bin/urweb{,-dev}
  '';

  # Be sure to keep the statically linked libraries
  dontDisableStatic = true;

  meta = {
    description = "Advanced purely-functional web programming language";
    homepage    = "http://www.impredicative.com/ur/";
    license     = stdenv.lib.licenses.bsd3;
    platforms   = stdenv.lib.platforms.linux ++ stdenv.lib.platforms.darwin;
    maintainers = [ stdenv.lib.maintainers.thoughtpolice stdenv.lib.maintainers.sheganinans ];
  };
}

