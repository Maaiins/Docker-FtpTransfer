[![](https://img.shields.io/badge/license-AGPL%20v3-blue.svg)](https://github.com/Maaiins/Docker-FTPTransfer/blob/master/LICENSE 'Project Licence') [![](https://img.shields.io/docker/stars/maaiins/ftp-transfer.svg)](https://hub.docker.com/r/maaiins/ftp-transfer 'Project DockerHub') [![](https://img.shields.io/docker/pulls/maaiins/ftp-transfer.svg)](https://hub.docker.com/r/maaiins/ftp-transfer 'Project DockerHub')

# Docker-FTPTransfer

### Usage

To run it:

    $ docker run \
          -e "FTP_SOURCE_ADDRESS=foo.bar" \
          -e "FTP_SOURCE_PORT=21" \ # Only needed if port is not 21, will be set to 21 if environment variable is not set
          -e "FTP_SOURCE_DIR=/foo" \  # Only needed if dir is not root, will be set to / if environment variable is not set
          -e "FTP_SOURCE_REMOVE_DIR=/foo /bar" \  # Only needed if you like to remove one directory or multiple directories
          -e "FTP_SOURCE_USER=user" \
          -e "FTP_SOURCE_PASSWORD=password" \
          -e "FTP_TARGET_ADDRESS=foo.bar" \
          -e "FTP_TARGET_PORT=21" \ # Only needed if port is not 21, will be set to 21 if environment variable is not set
          -e "FTP_TARGET_DIR=/bar" \  # Only needed if dir is not root, will be set to / if environment variable is not set
          -e "FTP_TARGET_REMOVE_DIR=/bar /foo" \  # Only needed if you like to remove one directory or multiple directories
          -e "FTP_TARGET_USER=user" \
          -e "FTP_TARGET_PASSWORD=password" \
          -e "FTP_TARGET_EXCLUDE_DIR=/bar /foo" \ # Only needed if you wish to exclude dirs from upload
          -e "FTP_TRANSFER_RETENTION=1d" \ # Only needed if you like to shedule transfer different to a day
          -v /foo/bar:/templates \ # Needed when you like to overwrite static files from the ftp source on target
          maaiins/ftp-transfer