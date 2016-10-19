# Archive
cd /Users/artemchuzhmarov/Desktop/wtfwordsios
xcrun xcodebuild -scheme AppStoreEng -configuration AppStoreEng archive -archivePath WTFChat/Build/Prod/WTFWords_AppStoreEng.xcarchive
xcrun xcodebuild -exportArchive -exportPath WTFChat/Build/Prod/ -archivePath WTFChat/Build/Prod/WTFWords_AppStoreEng.xcarchive -exportOptionsPlist WTFChat/Build/Options/options_prod.plist