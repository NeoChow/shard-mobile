Pod::Spec.new do |s|
  s.name             = 'ShardKit'
  s.version          = '0.1.2'
  s.summary          = 'iOS implementation of https://visly.app'
  s.homepage         = 'https://visly.app'
  s.author           = { 'Visly Inc.' => 'emil@visly.app' }
  s.source           = { :git => 'https://github.com/vislyhq/shard-mobile.git', :tag => s.version.to_s }
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  
  s.swift_version = '4.2'
  s.ios.deployment_target  = '10.0'

  s.source_files = 'ios/ShardKit/Classes/**/*'

  s.dependency 'Kingfisher', '~> 5.0.1'

  s.subspec 'ShardCore' do |core|
    core.source_files = 'ios/Libraries/Headers/*.h'
    core.vendored_libraries = "ios/Libraries/libshard.a"
    core.xcconfig = { "HEADER_SEARCH_PATHS" => "${PODS_ROOT}/ShardCore/Libraries/Headers" }
    core.preserve_paths = ["ios/Libraries/libshard.a", "ios/Libraries/Headers/libshard.h"]
    core.public_header_files = "ios/Libraries/Headers/*.h"
    core.requires_arc = false
  end
end
