#!/bin/bash

# Extract Firebase Web Config from iOS GoogleService-Info.plist
# Run this script to get the config values for web/settlement.html

echo "================================================"
echo "Firebase Web Configuration"
echo "================================================"
echo ""

PLIST_FILE="ios/Runner/GoogleService-Info.plist"

if [ ! -f "$PLIST_FILE" ]; then
    echo "Error: $PLIST_FILE not found"
    exit 1
fi

# Extract values using plutil or grep
if command -v plutil &> /dev/null; then
    echo "Using plutil to extract values..."
    API_KEY=$(plutil -extract API_KEY raw "$PLIST_FILE")
    PROJECT_ID=$(plutil -extract PROJECT_ID raw "$PLIST_FILE")
    STORAGE_BUCKET=$(plutil -extract STORAGE_BUCKET raw "$PLIST_FILE")
    APP_ID=$(plutil -extract GOOGLE_APP_ID raw "$PLIST_FILE")
    SENDER_ID=$(plutil -extract GCM_SENDER_ID raw "$PLIST_FILE")
else
    echo "Using grep to extract values..."
    API_KEY=$(grep -A 1 "API_KEY" "$PLIST_FILE" | grep "<string>" | sed 's/<[^>]*>//g' | xargs)
    PROJECT_ID=$(grep -A 1 "PROJECT_ID" "$PLIST_FILE" | grep "<string>" | sed 's/<[^>]*>//g' | xargs)
    STORAGE_BUCKET=$(grep -A 1 "STORAGE_BUCKET" "$PLIST_FILE" | grep "<string>" | sed 's/<[^>]*>//g' | xargs)
    APP_ID=$(grep -A 1 "GOOGLE_APP_ID" "$PLIST_FILE" | grep "<string>" | sed 's/<[^>]*>//g' | xargs)
    SENDER_ID=$(grep -A 1 "GCM_SENDER_ID" "$PLIST_FILE" | grep "<string>" | sed 's/<[^>]*>//g' | xargs)
fi

echo "Copy and paste this into web/settlement.html (line 186):"
echo ""
echo "const firebaseConfig = {"
echo "    apiKey: \"$API_KEY\","
echo "    authDomain: \"$PROJECT_ID.firebaseapp.com\","
echo "    projectId: \"$PROJECT_ID\","
echo "    storageBucket: \"$STORAGE_BUCKET\","
echo "    messagingSenderId: \"$SENDER_ID\","
echo "    appId: \"$APP_ID\""
echo "};"
echo ""
echo "================================================"
echo "Also update lib/services/settlement_share_service.dart (line 56):"
echo ""
echo "const baseUrl = 'https://$PROJECT_ID.web.app';"
echo ""
echo "================================================"
