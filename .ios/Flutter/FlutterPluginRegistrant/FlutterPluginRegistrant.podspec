#
# Generated file, do not edit.
#

Pod::Spec.new do |s|
  s.name             = 'FlutterPluginRegistrant'
  s.version          = '0.0.1'
  s.summary          = 'Registers plugins with your flutter app'
  s.description      = <<-DESC
Depends on all your plugins, and provides a function to register them.
                       DESC
  s.homepage         = 'https://flutter.dev'
  s.license          = { :type => 'BSD' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.ios.deployment_target = '9.0'
  s.source_files =  "Classes", "Classes/**/*.{h,m}"
  s.source           = { :path => '.' }
  s.public_header_files = './Classes/**/*.h'
  s.static_framework    = true
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.dependency 'Flutter'
  s.dependency 'battery'
  s.dependency 'connectivity'
  s.dependency 'core_location_fluttify'
  s.dependency 'firebase_admob'
  s.dependency 'firebase_core'
  s.dependency 'flutter_dlna'
  s.dependency 'foundation_fluttify'
  s.dependency 'image_gallery_saver'
  s.dependency 'janalytics_fluttify'
  s.dependency 'jcore_fluttify'
  s.dependency 'jpush_flutter'
  s.dependency 'package_info'
  s.dependency 'path_provider'
  s.dependency 'permission_handler'
  s.dependency 'screen'
  s.dependency 'shared_preferences'
  s.dependency 'sqflite'
  s.dependency 'url_launcher'
  s.dependency 'video_player'
  s.dependency 'wakelock'
  s.dependency 'webview_flutter'
end
