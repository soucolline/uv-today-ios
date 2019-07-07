source 'https://cdn.cocoapods.org/'

# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'swiftUV' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for swiftUV
  pod 'SwiftLint', '= 0.33'
  pod 'SVProgressHUD', '~> 2.2'
  pod 'PopupDialog', '= 1.1.0'
  pod 'ZLogger', '= 1.1.0'
  pod 'Swinject', '= 2.6.2'
  pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git', :tag => '4.3.1'

end

target 'swiftUVTests' do
  use_frameworks!
  pod 'Nimble', '= 8.0.2'
  pod 'Cuckoo', '= 1.0.6'
end

plugin 'cocoapods-keys', {
  :project => "swiftUV",
  :keys => [
  "DarkSkyApiKey",
  "SentryDSN"
]}

