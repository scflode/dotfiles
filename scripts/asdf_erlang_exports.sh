export CPPFLAGS="${CPPFLAGS+"$CPPFLAGS "}-I/opt/homebrew/opt/unixodbc/include"
export LDFLAGS="${LDFLAGS+"$LDFLAGS "}-L/opt/homebrew/opt/unixodbc/lib"
export KERL_CONFIGURE_OPTIONS="--with-odbc=/opt/homebrew/opt/unixodbc"
export KERL_BUILD_DOCS=yes
