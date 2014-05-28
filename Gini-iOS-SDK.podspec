Pod::Spec.new do |s|
  s.name     = 'Gini-iOS-SDK'
  s.version  = '0.0.1'
  s.license  = 'MIT'
  s.summary  = 'A delightful SDK for integrating Gini into other apps.'
  s.homepage = 'https://github.com/gini/gini-sdk-ios'
  s.social_media_url = 'https://twitter.com/gini'
  s.authors  = { 'Gini GmbH' => 'info@gini.net' }
  s.source   = { :git => 'git@github.com:gini/gini-sdk-ios.git', :commit => '33ed2501509db6056189f9a77dc56dff2caac2f6' }
  s.requires_arc = true
  s.platform     = :ios, "7.0"
  s.public_header_files = 'GiniSDK/**/*.h'
  s.source_files = 'GiniSDK'
  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  s.dependency "Bolts", "1.1.0"
end
