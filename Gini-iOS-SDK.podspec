Pod::Spec.new do |s|
s.name     = 'Gini-iOS-SDK'
s.version  = '0.5.2'
s.license  = 'MIT'
s.summary  = 'An SDK for integrating the magical Gini technology into other apps.'
s.homepage = 'https://github.com/gini/gini-sdk-ios'
s.social_media_url = 'https://twitter.com/gini'
s.authors  = { 'Gini GmbH' => 'info@gini.net' }
s.source   = { :git => 'https://github.com/gini/gini-sdk-ios.git', :tag => s.version.to_s }
s.documentation_url = 'http://developer.gini.net/gini-sdk-ios/docs/'
s.requires_arc = true
s.platform     = :ios, "7.0"
s.public_header_files = 'Gini-iOS-SDK/**/*.h'
s.source_files = 'Gini-iOS-SDK'
s.default_subspec = 'Lite'

s.subspec 'Lite' do |lite|
lite.dependency "Bolts", "~> 1.2.2"
end

s.subspec 'TrustKit' do |trustkit|
trustkit.xcconfig =
{ 'OTHER_CFLAGS' => '$(inherited) -DGINISDK_OFFER_TRUSTKIT' }
trustkit.dependency "TrustKit", "~> 1.5.2"
end
end
