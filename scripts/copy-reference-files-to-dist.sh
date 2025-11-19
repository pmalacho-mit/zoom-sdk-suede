#!/bin/bash

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REFERENCE_DIR="${SCRIPTS_DIR}/../reference/videosdk-web-sample"
DEST_DIR="${SCRIPTS_DIR}/../dist"
REACT_ROUTER_STUB_PATH="$DEST_DIR/react-router.stub.ts"

# Array of supported react-router functions
SUPPORTED_REACT_ROUTER_IMPORTS=("useSearchParams")

process_react_router_imports() {
  local file_path="$1"
  
  if [[ ! "$file_path" =~ \.(tsx?|jsx?)$ ]]; then
    return
  fi
  
  if ! grep -q "from ['\"]react-router['\"]" "$file_path"; then
    return
  fi
  
  # Extract the imported items from react-router
  local import_line=$(grep "from ['\"]react-router['\"]" "$file_path")
  
  # Extract what's being imported (handle both named and default imports)
  local imports=$(echo "$import_line" | sed -n "s/.*import[[:space:]]*{\([^}]*\)}.*/\1/p" | tr -d ' ')
  
  if [ -z "$imports" ]; then
    echo "Warning: Could not parse react-router imports in $file_path"
    return
  fi
  
  # Split imports by comma
  IFS=',' read -ra IMPORT_ARRAY <<< "$imports"
  
  for import_item in "${IMPORT_ARRAY[@]}"; do
    local base_import=$(echo "$import_item" | sed 's/[[:space:]]*as[[:space:]].*//' | tr -d ' ')
    
    local is_supported=false
    for supported in "${SUPPORTED_REACT_ROUTER_IMPORTS[@]}"; do
      if [ "$base_import" = "$supported" ]; then
        is_supported=true
        break
      fi
    done
    
    if [ "$is_supported" = false ]; then
      echo "Warning: Unsupported react-router import '$base_import' in $file_path, skipping replacement"
      return
    fi
  done
  
  local file_dir=$(dirname "$file_path")
  local rel_path=$(realpath --relative-to="$file_dir" "$REACT_ROUTER_STUB_PATH")
  
  # Remove the .ts extension and ensure it starts with ./
  rel_path="${rel_path%.ts}"
  if [[ ! "$rel_path" =~ ^\. ]]; then
    rel_path="./$rel_path"
  fi
  
  # Replace the import line, preserving the original quote style
  sed -i "s|from ['\"]react-router['\"]|from '${rel_path}'|g; s|from \"react-router\"|from \"${rel_path}\"|g" "$file_path"
  echo "  → Replaced react-router import with relative import: $rel_path"
}

if [ ! -d "$REFERENCE_DIR/node_modules" ]; then
  echo "Installing dependencies in $REFERENCE_DIR..."
  npm install --prefix "$REFERENCE_DIR"
fi

if [ ! -d "$REFERENCE_DIR/dist" ]; then
  echo "Building project in $REFERENCE_DIR..."
  npm run build --prefix "$REFERENCE_DIR"
fi

# Map of source directories/files to destination paths
declare -A FILE_MAP=(
  # Custom remappings (built assets)
  ["dist/lib"]="assets/lib"
  ["dist/assets/processors"]="assets/static/processors"
)

# Standard src/ to root mappings
SRC_FILES=(
  # Source Files
  "feature/video/video.tsx"
  "feature/video/video-single.tsx"
  "feature/video/video-attach.tsx"
  "feature/video/video-constants.ts"
  "feature/video/video-types.d.ts"
  "feature/video/video.scss"
  "feature/video/video-layout-helper.ts"
  # Contexts
  "feature/video/context/avatar-context.ts"
  # Components
  "feature/video/components/avatar.tsx"
  "feature/video/components/avatar.scss"
  "feature/video/components/video-footer.tsx"
  "feature/video/components/video-footer.scss"
  "feature/video/components/video-footer-utils.ts"
  "feature/video/components/share-view"
  "feature/video/components/remote-camera-control.tsx"
  "feature/video/components/remote-camera-control.scss"
  "feature/video/components/report-btn.tsx"
  "feature/video/components/report-btn.scss"
  "feature/video/components/pagination.tsx"
  "feature/video/components/pagination.scss"
  "feature/video/components/draggable.tsx"
  "feature/video/components/camera.tsx"
  "feature/video/components/microphone.tsx"
  "feature/video/components/screen-share.tsx"
  "feature/video/components/audio-video-statistic.tsx"
  "feature/video/components/recording.tsx"
  "feature/video/components/live-transcription.tsx"
  "feature/video/components/live-transcription.scss"
  "feature/video/components/leave.tsx"
  "feature/video/components/transcription-subtitle.tsx"
  "feature/video/components/transcription-subtitle.scss"
  "feature/video/components/recording-ask-modal.tsx"
  "feature/video/components/recording-ask-modal.scss"
  "feature/video/components/live-stream.tsx"
  "feature/video/components/video-mask-modal.tsx"
  "feature/video/components/video-mask-modal.scss"
  "feature/video/components/avatar-more.tsx"
  "feature/video/components/share-bar.tsx"
  "feature/video/components/share-bar.scss"
  "feature/video/components/share-indication.tsx"
  "feature/video/components/share-indication.scss"
  "feature/video/components/call-out-modal.tsx"
  "feature/video/components/call-out-modal.scss"
  "feature/video/components/crc-call-out-modal.tsx"
  # Hooks
  "feature/video/hooks/useParticipantsChange.ts"
  "feature/video/hooks/useCanvasDimension.ts"
  "feature/video/hooks/useNetworkQuality.ts"
  "feature/video/hooks/useAvatarAction.ts"
  "feature/video/hooks/useActiveMediaFailed.ts"
  "feature/video/hooks/useCleanUp.ts"
  "feature/video/hooks/useAttachPagination.ts"
  "feature/video/hooks/useAvtiveVideo.ts"
  "feature/video/hooks/useVideoAspectRatio.ts"
  "feature/video/hooks/useGridLayout.ts"
  "feature/video/hooks/useRenderVideo.ts"
  "feature/video/hooks/useVideoGridStyle.ts"
  "feature/video/hooks/useSpotlightVideo.ts"
  "feature/video/hooks/useCameraControl.ts"
  "feature/video/hooks/useGalleryLayout.ts"
  "feature/video/hooks/usePagination.ts"
  "feature/video/hooks/useMultiShare.ts"
  "feature/video/hooks/useShare.ts"
  "feature/video/hooks/useRemoteControl.tsx"
  "feature/video/hooks/useScreenOrientation.ts"
  "feature/video/hooks/useAudioLevel.ts"
  # General Hooks
  "hooks"
  # Utils
  "utils/util.ts"
  "utils/platform.ts"
  # Contexts
  "context/zoom-context.ts"
  "context/media-context.ts"
  # Components
  "component/loading-layer.tsx"
  "component/loading-layer.scss"
  "component/icon-font.tsx"
  "component/audio-animation-icon.tsx"
  "component/svgs"
  # Types
  "index-types.d.ts"
)

# Populate the map with src/ prefix for source files
for file in "${SRC_FILES[@]}"; do
  FILE_MAP["src/$file"]="$file"
done

mkdir -p "$DEST_DIR"

# Execute the copy
for source_path in "${!FILE_MAP[@]}"; do
  dest_path="${FILE_MAP[$source_path]}"
  full_source="$REFERENCE_DIR/$source_path"
  full_dest="$DEST_DIR/$dest_path"
  
  if [ -e "$full_source" ]; then
    mkdir -p "$(dirname "$full_dest")"
    
    if [ -d "$full_source" ]; then
      echo "Copying directory: $source_path -> $dest_path"
      cp -r "$full_source" "$(dirname "$full_dest")/"
      # Process react-router imports in all files in the directory
      find "$full_dest" -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \) | while read -r file; do
        process_react_router_imports "$file"
      done
    else
      echo "Copying file: $source_path -> $dest_path"
      cp "$full_source" "$full_dest"
      process_react_router_imports "$full_dest"
    fi
  else
    echo "Warning: $full_source does not exist, skipping..."
  fi
done

echo "Static assets copy complete!"