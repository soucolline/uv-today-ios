source 'https://cdn.cocoapods.org/'

inhibit_all_warnings!

platform :ios, '14.0'

target 'swiftUV' do
  use_frameworks!

  # Pods for swiftUV
  pod 'SwiftLint', '= 0.48.0'
  pod 'Bugsnag'
end

target 'swiftUVTests' do
  use_frameworks!
  pod 'Cuckoo', '= 1.8.1'
end

plugin 'cocoapods-keys', {
  :project => "swiftUV",
  :keys => [
  "OpenWeatherMapApiKey",
  "BugsnagApiKey"
]}

post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      end
    end
end
