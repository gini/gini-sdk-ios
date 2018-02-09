source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'

def production_pods
    pod 'Gini-iOS-SDK', :path => './'
    pod 'Gini-iOS-SDK/Pinning', :path => './'
end

def testing_pods
    pod 'Gini-iOS-SDK', :path => './'
    pod 'Gini-iOS-SDK/Pinning', :path => './'
    pod 'Kiwi', '~>2.4.0'
end

target 'Gini-iOS-SDKTests' do
    testing_pods
end

target 'GiniSDK Example' do
    production_pods
end
