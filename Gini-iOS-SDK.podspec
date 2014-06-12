Pod::Spec.new do |s|
  s.name     = 'Gini-iOS-SDK'
  s.version  = '0.0.1'
  s.license  = 'MIT'
  s.summary  = 'A delightful SDK for integrating Gini into other apps.'
  s.homepage = 'https://github.com/gini/gini-sdk-ios'
  s.social_media_url = 'https://twitter.com/gini'
  s.authors  = { 'Gini GmbH' => 'info@gini.net' }
  s.source   = { :git => 'git@github.com:gini/gini-sdk-ios.git', :commit => '37499141396066b46cea1d88ba36f8fbbb65fd54' }
  s.requires_arc = true
  s.platform     = :ios, "7.0"
  s.public_header_files = 'Gini-iOS-SDK/**/*.h'
  s.source_files = 'Gini-iOS-SDK'
  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  s.dependency "Bolts", "1.1.0"
end
