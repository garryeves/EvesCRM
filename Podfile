# Uncomment this line to define a global platform for your project
# platform :ios, '6.0'
platform :ios, "10.0"
use_frameworks!

project '/Users/garryeves/Documents/xcode/EvesCRM/Contacts Dashboard.xcodeproj '

target 'EvesCRM' do
pod 'Google/SignIn'
pod 'SwiftyDropbox'
end

post_install do |installer|
    app_plist = “/Users/garryeves/Documents/xcode/EvesCRM/EvesCRM/Info.plist”
    plist_buddy = "/usr/libexec/PlistBuddy"

    version = `#{plist_buddy} -c "Print CFBundleShortVersionString" #{app_plist}`
    version = `echo "#{version}" | tr -d '\n'`

    puts "Updating CocoaPods frameworks' version numbers to #{version}"

    installer.pods_project.targets.each do |target|  
        `#{plist_buddy} -c "Set CFBundleShortVersionString #{version}" "Pods/Target Support Files/#{target}/Info.plist"`  
    end  
end
