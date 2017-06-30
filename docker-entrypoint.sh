#!/bin/sh
set -e

stdout () {
cat >&1 <<-EOT
${1}
EOT
}

stderr () {
cat >&2 <<-EOT
${1}
EOT
}

exists () {
if [ -z ${1} ]; then
    # ----
    stderr "ERROR: you need to set ${2}"
    # ----

    exit 1
else
    # ----
    stdout "OK: ${2} set"
    # ----
fi
}


echo "     _ _     _ _             _ _ "
echo "    |   \   /   |           (_)_)"
echo "    | |\ \ / /| | __ _  __ _ _ _ _  __   __"
echo "    | | \ _ / | |/ _\` |/ _\` | | | '_  \\/ __|"
echo "    | |       | | (_| | (_| | | | | | |\\__ \\"
echo "    |_|       |_|\__,_|\__,_|_|_|_| |_||__ /"

# ----
stdout "Checking requirements..."
# ----

exists ${FTP_SOURCE_ADDRESS} "FTP_SOURCE_ADDRESS"
exists ${FTP_SOURCE_USER} "FTP_SOURCE_USER"
exists ${FTP_SOURCE_PASSWORD} "FTP_SOURCE_PASSWORD"
exists ${FTP_TARGET_ADDRESS} "FTP_TARGET_ADDRESS"
exists ${FTP_TARGET_USER} "FTP_TARGET_USER"
exists ${FTP_TARGET_PASSWORD} "FTP_TARGET_PASSWORD"

if [ -z ${FTP_SOURCE_PORT} ]; then
    # ----
    stdout "INFO: FTP_SOURCE_PORT not set, default 21"
    # ----

    FTP_SOURCE_PORT=21
fi

if [ -z ${FTP_SOURCE_DIR} ]; then
    # ----
    stdout "INFO: FTP_SOURCE_DIR not set, default /*"
    # ----

    FTP_SOURCE_DIR="/*"
fi

if [ -z ${FTP_TARGET_PORT} ]; then
    # ----
    stdout "INFO: FTP_TARGET_PORT not set, default 21"
    # ----

    FTP_TARGET_PORT=21
fi

if [ -z ${FTP_TARGET_DIR} ]; then
    # ----
    stdout "INFO: FTP_TARGET_DIR not set, default /*"
    # ----

    FTP_TARGET_DIR="/"
    DIR="/ftp"
else
    DIR="/$(basename "/clone.netmeile.de/")"
    FTP_TARGET_DIR=$(dirname "/clone.netmeile.de/")

    # ----
    stdout "Cleanup remote files"
    # ----

    printf "rm -r ${DIR}/*\nquit\n" | ncftp -u ${FTP_TARGET_USER} -p ${FTP_TARGET_PASSWORD} -P ${FTP_TARGET_PORT} ${FTP_TARGET_ADDRESS}
fi

# ----
stdout "Successfully checked requirements!"
# ----

# ----
stdout "Cleanup local folders"
# ----

rm -rf '/ftp'
rm -rf "${DIR}"
mkdir -p '/ftp'

# ----
stdout "Begin transaction $(date)"
# ----

# ----
stdout "Collecting files from source ftp"
# ----

ncftpget -R -T -v -u ${FTP_SOURCE_USER} -p ${FTP_SOURCE_PASSWORD} -P ${FTP_SOURCE_PORT} ${FTP_SOURCE_ADDRESS} '/ftp' "${FTP_SOURCE_DIR}" 2>&1 || echo "INFO: Try to continue ftp-transfer"

if [ -z "${BASH_COMMAND}" ]; then
    # ----
    stdout "INFO: BASH_COMMAND not set"
    # ----
else
    # ----
    stdout "Executing bash command"
    # ----

    cd "/ftp"
    ${BASH_COMMAND} >&1 || echo "INFO: Try to continue ftp-transfer"
fi

# ----
stdout "Moving templates to source files"
# ----

cp -a /templates/. /ftp
if [ ${DIR} != "/ftp" ]; then
    mv -v '/ftp' ${DIR}
fi

# ----
stdout "Upload files to target ftp"
# ----

ncftpput -R -v -m -u ${FTP_TARGET_USER} -p ${FTP_TARGET_PASSWORD} -P ${FTP_TARGET_PORT} ${FTP_TARGET_ADDRESS} "${FTP_TARGET_DIR}" "${DIR}" 2>&1

# ----
stdout "End transaction $(date)"
# ----