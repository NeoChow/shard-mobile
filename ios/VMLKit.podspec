Pod::Spec.new do |s|
  s.name             = 'VMLKit'
  s.version          = '0.1.1'
  s.summary          = 'iOS implementation of https://visly.app'
  s.homepage         = 'https://visly.app'
  s.author           = { 'Visly Inc.' => 'emil@visly.app' }
  s.source           = { :git => 'https://github.com/vislyhq/vml-mobile.git', :tag => s.version.to_s }
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  
  s.swift_version = '4.2'
  s.ios.deployment_target  = '10.0'

  s.source_files = 'VMLKit/Classes/**/*'

  s.dependency 'Kingfisher', '~> 5.0.1'

  s.subspec 'VMLCore' do |core|
    core.source_files = 'Libraries/Headers/*.h'
    core.vendored_libraries = "Libraries/libvml.a"
    core.xcconfig = { "HEADER_SEARCH_PATHS" => "${PODS_ROOT}/VMLCore/Libraries/Headers" }
    core.preserve_paths = ["Libraries/libvml.a", "Libraries/Headers/libvml.h"]
    core.public_header_files = "Libraries/Headers/*.h"
    core.requires_arc = false
  end
end
