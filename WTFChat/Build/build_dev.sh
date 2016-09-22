# Archive
cd /Users/artemchuzhmarov/Desktop/wtfwordsios
xcrun xcodebuild -scheme Release -configuration Release archive -archivePath WTFChat/Build/Dev/WTFWords_Release.xcarchive
xcrun xcodebuild -exportArchive -exportPath WTFChat/Build/Dev/ -archivePath WTFChat/Build/Dev/WTFWords_Release.xcarchive -exportOptionsPlist WTFChat/Build/Options/options_dev.plist