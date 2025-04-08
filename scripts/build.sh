#!/bin/bash

# Exit on error
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building ConAir Widget...${NC}"

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$SCRIPT_DIR/ConAirWidget"

# Build the project
xcodebuild \
    -project "$PROJECT_DIR/ConAirWidget.xcodeproj" \
    -scheme ConAirWidget \
    -configuration Release \
    -derivedDataPath "$PROJECT_DIR/build" \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

# Check if build was successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Build successful!${NC}"
    echo "The built app is located in: $PROJECT_DIR/build/Build/Products/Release/ConAirWidget.app"
else
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi 