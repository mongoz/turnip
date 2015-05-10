#!/bin/sh
set -e

mkdir -p "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

realpath() {
  DIRECTORY=$(cd "${1%/*}" && pwd)
  FILENAME="${1##*/}"
  echo "$DIRECTORY/$FILENAME"
}

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1"`.mom\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm\""
      xcrun mapc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE=$(realpath "${PODS_ROOT}/$1")
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    /*)
      echo "$1"
      echo "$1" >> "$RESOURCES_TO_COPY"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/bubbleFlatIncoming.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/bubbleFlatIncoming@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/bubbleFlatOutgoing.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/bubbleFlatOutgoing@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/bubbleSquareIncoming.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/bubbleSquareIncoming@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/bubbleSquareOutgoing.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/bubbleSquareOutgoing@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/buttonSend.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/buttonSend@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/buttonSendFlat.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/buttonSendFlat@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/buttonSendHighlighted.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/buttonSendHighlighted@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/buttonSendHighlightedFlat.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/buttonSendHighlightedFlat@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/imageBar.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/imageBar@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/imageBarFlat.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/imageBarFlat@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/imageInput.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/imageInput@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/imageInputFlat.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/imageInputFlat@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/messageBubbleBlue.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/messageBubbleBlue@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/messageBubbleGray.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/messageBubbleGray@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/messageBubbleGreen.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/messageBubbleGreen@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/messageBubbleHighlighted.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/messageBubbleHighlighted@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/messageBubbleTyping.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/messageBubbleTyping@2x.png"
  install_resource "Google-Maps-iOS-SDK/GoogleMaps.framework/Versions/A/Resources/GoogleMaps.bundle"
  install_resource "ParseUI/ParseUI/Resources/Localization/en.lproj"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/bubbleFlatIncoming.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/bubbleFlatIncoming@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/bubbleFlatOutgoing.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/bubbleFlatOutgoing@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/bubbleSquareIncoming.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/bubbleSquareIncoming@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/bubbleSquareOutgoing.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/bubbleSquareOutgoing@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/buttonSend.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/buttonSend@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/buttonSendFlat.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/buttonSendFlat@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/buttonSendHighlighted.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/buttonSendHighlighted@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/buttonSendHighlightedFlat.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/buttonSendHighlightedFlat@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/imageBar.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/imageBar@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/imageBarFlat.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/imageBarFlat@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/imageInput.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/imageInput@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/imageInputFlat.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/imageInputFlat@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/messageBubbleBlue.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/messageBubbleBlue@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/messageBubbleGray.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/messageBubbleGray@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/messageBubbleGreen.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/messageBubbleGreen@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/messageBubbleHighlighted.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/messageBubbleHighlighted@2x.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/messageBubbleTyping.png"
  install_resource "AMBubbleTableViewController/AMBubbleTableViewController/Resources/messageBubbleTyping@2x.png"
  install_resource "Google-Maps-iOS-SDK/GoogleMaps.framework/Versions/A/Resources/GoogleMaps.bundle"
  install_resource "ParseUI/ParseUI/Resources/Localization/en.lproj"
fi

rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]]; then
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "$XCASSET_FILES" ]
then
  case "${TARGETED_DEVICE_FAMILY}" in
    1,2)
      TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
      ;;
    1)
      TARGET_DEVICE_ARGS="--target-device iphone"
      ;;
    2)
      TARGET_DEVICE_ARGS="--target-device ipad"
      ;;
    *)
      TARGET_DEVICE_ARGS="--target-device mac"
      ;;
  esac

  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "`realpath $PODS_ROOT`*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${IPHONEOS_DEPLOYMENT_TARGET}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
