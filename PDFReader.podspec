Pod::Spec.new do |s|
  s.name         = "PDFReader"
  s.version      = "1.0.0"
  s.summary      = "schwa open source PDF reader"
  s.homepage     = "https://github.com/schwa/iOS-PDF-Reader"
  s.license      = { :type => 'tbd', :file => 'LICENSE.txt'}
  s.author       = { "schwa" => "schwa"}
  s.source       = { :git => "https://github.com/ivygulch/iOS-PDF-Reader" }
  s.platform     = :ios, '6.0'
  s.source_files = '{Source,Externals}/**/*'
  s.frameworks   = 'Foundation', 'UIKit', 'CoreGraphics', 'MediaPlayer', 'MobileCoreServices', 'QuartzCore'
  s.requires_arc = true
end

