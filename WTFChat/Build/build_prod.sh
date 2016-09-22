# Archive
cd /Users/artemchuzhmarov/Desktop/wtfwordsios
xcrun xcodebuild -scheme AppStore -configuration AppStore archive -archivePath WTFChat/Build/Prod/WTFWords_AppStore.xcarchive
xcrun xcodebuild -exportArchive -exportPath WTFChat/Build/Prod/ -archivePath WTFChat/Build/Prod/WTFWords_AppStore.xcarchive -exportOptionsPlist WTFChat/Build/Options/options_prod.plist