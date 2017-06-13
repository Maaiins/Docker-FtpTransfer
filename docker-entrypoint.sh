#!/bin/sh
set -e

# ----
# Check env variables

echo "     _ _     _ _             _ _ "
echo "    |   \   /   |           (_)_)"
echo "    | |\ \ / /| | __ _  __ _ _ _ _  __   __"
echo "    | | \ _ / | |/ _\` |/ _\` | | | '_  \\/ __|"
echo "    | |       | | (_| | (_| | | | | | |\\__ \\"
echo "    |_|       |_|\__,_|\__,_|_|_|_| |_||__ /"
cat >&1 <<-EOT

----
Checking requirements...
----

EOT

# Source FTP
if [ -z ${FTP_SOURCE_ADDRESS} ]; then
    cat >&2 <<-EOT
		ERROR: you need to specify FTP_SOURCE_ADDRESS
	EOT
    exit 1
else
    cat >&1 <<-EOT
		OK: FTP_SOURCE_ADDRESS is given
	EOT
fi

if [ -z ${FTP_SOURCE_USER} ]; then
    cat >&2 <<-EOT
		ERROR: you need to specify FTP_SOURCE_USER
	EOT
    exit 1
else
    cat >&1 <<-EOT
		OK: FTP_SOURCE_USER is given
	EOT
fi

if [ -z ${FTP_SOURCE_PASSWORD} ]; then
    cat >&2 <<-EOT
		ERROR: you need to specify FTP_SOURCE_PASSWORD
	EOT
    exit 1
else
    cat >&1 <<-EOT
		OK: FTP_SOURCE_PASSWORD is given
	EOT
fi

# Target FTP
if [ -z ${FTP_TARGET_ADDRESS} ]; then
    cat >&2 <<-EOT
		ERROR: you need to specify FTP_TARGET_ADDRESS
	EOT
    exit 1
else
    cat >&1 <<-EOT
		OK: FTP_TARGET_ADDRESS is given
	EOT
fi

if [ -z ${FTP_TARGET_USER} ]; then
    cat >&2 <<-EOT
		ERROR: you need to specify FTP_TARGET_USER
	EOT
    exit 1
else
    cat >&1 <<-EOT
		OK: FTP_TARGET_USER is given
	EOT
fi

if [ -z ${FTP_TARGET_PASSWORD} ]; then
    cat >&2 <<-EOT
		ERROR: you need to specify FTP_TARGET_PASSWORD
	EOT
    exit 1
else
    cat >&1 <<-EOT
		OK: FTP_TARGET_PASSWORD is given
	EOT
fi

# ----
# Set default values if not provided

# Source FTP
if [ -z ${FTP_SOURCE_PORT} ]; then
    cat >&1 <<-EOT
		INFO: FTP_SOURCE_PORT not set, default 21
	EOT
    FTP_SOURCE_PORT=21
fi

if [ -z ${FTP_SOURCE_DIR} ]; then
    cat >&1 <<-EOT
		INFO: FTP_SOURCE_DIR not set, default "/*"
	EOT
    FTP_SOURCE_DIR="/*"
fi

# Target FTP
if [ -z ${FTP_TARGET_PORT} ]; then
    cat >&1 <<-EOT
		INFO: FTP_TARGET_PORT not set, default 21
	EOT
    FTP_TARGET_PORT=21
fi

if [ -z ${FTP_TARGET_DIR} ]; then
    cat >&1 <<-EOT
		INFO: FTP_TARGET_DIR not set, default "/*"
	EOT
    FTP_TARGET_DIR="/*"
    DIR="/ftp"
else
    DIR="/$(basename "${FTP_TARGET_DIR}")"
    FTP_TARGET_DIR=$(dirname "${FTP_TARGET_DIR}")
fi

# Retention
if [ -z ${FTP_TRANSFER_RETENTION} ]; then
    cat >&1 <<-EOT
		INFO: FTP_TRANSFER_RETENTION not set, default 1d
	EOT
    FTP_TRANSFER_RETENTION=1d
fi

cat >&1 <<-EOT

----
Successfully checked requirements!
----
EOT

transfer ()
{
# ----
# Cleanup
rm -rf '/ftp'
mkdir -p '/ftp'

cat >&1 <<-EOT

----
Begin transaction $(date)
----

EOT

# ----
# Empty source folder
if [ -z ${FTP_SOURCE_REMOVE_DIR} ]; then
    cat >&1 <<-EOT
		INFO: FTP_SOURCE_REMOVE_DIR not set
	EOT
else
    cat >&1 <<-EOT
		----
        Removing folders from source
        ----

	EOT

    ncftp -u ${FTP_SOURCE_USER} -p ${FTP_SOURCE_PASSWORD} -P ${FTP_SOURCE_PORT} ${FTP_SOURCE_ADDRESS} <<EOF
rm -rf ${FTP_SOURCE_REMOVE_DIR}
quit
EOF
fi

# ----
# Empty target folder
if [ -z ${FTP_TARGET_REMOVE_DIR} ]; then
    cat >&1 <<-EOT
		INFO: FTP_TARGET_REMOVE_DIR not set
	EOT
else
    cat >&1 <<-EOT
		----
        Removing folders from target
        ----

	EOT

    ncftp -u ${FTP_TARGET_USER} -p ${FTP_TARGET_PASSWORD} -P ${FTP_TARGET_PORT} ${FTP_TARGET_ADDRESS} <<EOF
rm -rf ${FTP_TARGET_REMOVE_DIR}
quit
EOF
fi

# ----
# Get files from source
cat >&1 <<-EOT
    ----
    Collecting files from source ftp
    ----

EOT

ncftpget -R -v -u ${FTP_SOURCE_USER} -p ${FTP_SOURCE_PASSWORD} -P ${FTP_SOURCE_PORT} ${FTP_SOURCE_ADDRESS} '/ftp' "${FTP_SOURCE_DIR}"

# ----
# Move template files
cat >&1 <<-EOT
    ----
    Moving templates to source files
    ----

EOT

cp -a /templates/. /ftp
if [ ${DIR} != "/ftp" ]; then
    rm -rf "${DIR}"
    mv -v '/ftp' ${DIR}
fi

# ----
# Put files to target
cat >&1 <<-EOT
    ----
    Upload files to target ftp
    ----

EOT

ncftpput -R -v -m -u ${FTP_TARGET_USER} -p ${FTP_TARGET_PASSWORD} -P ${FTP_TARGET_PORT} ${FTP_TARGET_ADDRESS} "${FTP_TARGET_DIR}" "${DIR}"

cat >&1 <<-EOT

----
End transaction $(date)
----
EOT
}

while true; do
    transfer
    if [ "${FTP_TRANSFER_RETENTION}" = false ] ; then
        break
    fi
    sleep ${FTP_TRANSFER_RETENTION}
done