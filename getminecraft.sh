#!/bin/sh
set -e

PURPUR_VERSION=$1

# Retrieve the latest build number
LATEST_BUILD=$(curl -s "https://api.purpurmc.org/v2/purpur/${PURPUR_VERSION}/" | jq -r '.builds.latest')

echo "------------------------------------------------------------------"
echo "Purpur version: $PURPUR_VERSION#$LATEST_BUILD :Build"
echo "------------------------------------------------------------------"

# Construct the download URL
DOWNLOAD_URL="https://api.purpurmc.org/v2/purpur/${PURPUR_VERSION}/${LATEST_BUILD}/download"

# Download the Purpur server JAR
curl -s -o purpur.jar "${DOWNLOAD_URL}"

echo "Purpur server downloaded successfully."
