#!/bin/sh
set -e

PURPUR_VERSION=$1

# Retrieve the latest build number
LATEST_BUILD=$(curl -s "https://api.purpurmc.org/v2/purpur/${PURPUR_VERSION}/" | jq -r '.builds.latest')

echo "------------------------------------------------------------------"
echo "Purpur version: ${PURPUR_VERSION}-${LATEST_BUILD}"
echo "------------------------------------------------------------------"

# Construct the download URL
DOWNLOAD_URL="https://api.purpurmc.org/v2/purpur/${PURPUR_VERSION}/${LATEST_BUILD}/download"
MD5=$(curl -s "https://api.purpurmc.org/v2/purpur/${PURPUR_VERSION}/${LATEST_BUILD}/" | jq -r '.md5')

# Download the Purpur server JAR
curl -s -o purpur.jar "${DOWNLOAD_URL}"

while true; do
  # download
  curl -s -o purpur.jar "$DOWNLOAD_URL"
  #mathing md5
  MD5_download=$(md5sum "purpur.jar" | awk '{print $1}')
  # Compair md5
  if [ "$MD5_download" = "${MD5}" ]; then
    echo "Purpur server downloaded successfully."
    break
  else
    echo "Purpur server downloaded with error"
    echo "${MD5_download} << download"
    echo "${MD5} << SAVED"
    rm purpur.jar
  fi
done
