PURPUR_VERSION=$1
LATEST_BUILD=$(curl -s "https://api.purpurmc.org/v2/purpur/${PURPUR_VERSION}/" | jq -r '.builds.latest')
echo ------------------------------------------------------------------
echo Purpur version: $PURPUR_VERSION#$LATEST_BUILD :Build
echo ------------------------------------------------------------------
DOWNLOAD_URL="https://api.purpurmc.org/v2/purpur/${PURPUR_VERSION}/${LATEST_BUILD}/download"
curl -s -o purpur.jar ${DOWNLOAD_URL}