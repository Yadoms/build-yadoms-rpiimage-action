#!/bin/bash -e

echo "Creating user : $UNAME"

# Add user $UNAME
useradd -m ${UNAME} -s /bin/bash

echo "Setup password"

# Set $UNAME password
echo "${UNAME}:${UPASS}" | chpasswd

echo "Setup authorizations (sudo, tty,...)"

# Add $UNAME to sudo group
adduser ${UNAME} sudo || true
adduser ${UNAME} audio || true
adduser ${UNAME} video || true
adduser ${UNAME} input || true
adduser ${UNAME} tty || true
