
Pod::Spec.new do |s|
  s.name             = 'VMLKit'
  s.version          = '0.0.1'
  s.summary          = 'iOS implementation of https://visly.app'
  s.homepage         = 'https://visly.app'
  s.author           = { 'Visly Inc.' => 'emil@visly.app' }
  s.source           = { :git => 'https://github.com/vislyhq/ios-vml-client.git', :tag => s.version.to_s }
  s.license          = { :type => 'MIT' }
  
  s.swift_version = '4.0'
  s.source_files = 'VMLKit/Classes/**/*'

  s.dependency 'Yoga', '~> 1.9.0'
  s.dependency 'Kingfisher', '~> 4.10.0'
end
