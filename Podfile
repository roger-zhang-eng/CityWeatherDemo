# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'
source 'https://github.com/CocoaPods/Specs.git'

# ignore all warnings from all pods
inhibit_all_warnings!

use_frameworks!

def common_pods
  pod 'RxCocoa', '~> 5.0'
  pod 'RxSwift', '~> 5.0'
  pod 'Action', '4.0.0'
  pod 'Alamofire', '~> 4.9'
  pod 'RxAlamofire', '~> 5.1'
  pod "RxAppState", '1.6.0'
  pod 'RxCoreLocation', '~> 1.4'
  pod 'SwiftLint', '~> 0.39'
end

target 'CityWeatherDemo' do
  common_pods
end

target 'CityWeatherDemoTests' do
    common_pods
    pod 'RxTest', '~> 5.1'
    pod 'RxBlocking', '~> 5.1'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      config.build_settings['SWIFT_VERSION'] = '5.0'
    end
  end
end
  

