source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'

def production_pods
    pod 'Bolts', '~>1.2.0'
    pod 'TrustKit'
end

def testing_pods
    pod 'Bolts', '~>1.2.0'
    pod 'TrustKit'
    pod 'Kiwi', '~>2.4.0'
end

target 'Gini-iOS-SDK' do
    production_pods
end

target 'Gini-iOS-SDKTests' do
    testing_pods
end

target 'GiniSDK Example' do
    production_pods
end
