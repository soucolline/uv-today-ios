source 'https://cdn.cocoapods.org/'

inhibit_all_warnings!

platform :ios, '12.0'

target 'swiftUV' do
  use_frameworks!

  # Pods for swiftUV
  pod 'SwiftLint', '= 0.40.3'
  pod 'SVProgressHUD', '= 2.2.5'
  pod 'PopupDialog', '= 1.1.1'
  pod 'ZLogger', '= 1.1.0'
  pod 'Swinject', '= 2.7.1'
  pod 'Bugsnag'
end

target 'swiftUVTests' do
  use_frameworks!
  pod 'Cuckoo', '= 1.4.1'
end

plugin 'cocoapods-keys', {
  :project => "swiftUV",
  :keys => [
  "DarkSkyApiKey",
  "BugsnagApiKey"
]}

post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
    end
end
