Pod::Spec.new do |s|
  s.name         = "CTImagePicker"
  s.version      = "0.0.1"
  s.summary      = "选择图片"
  s.description  = <<-DESC
                     一行代码选择图片
                   DESC
  s.homepage     = "https://github.com/Evan-CT/ImagePicker"
  s.license      = 'MIT'
  s.author       = { "Evan.Cheng" => "Evan_Tong@163.com" }
  s.source       = { :git => "https://github.com/Evan-CT/ImagePicker.git", :tag =>  s.version }

  s.platform     = :ios, '4.3'
  s.requires_arc = true

  s.public_header_files = 'CTCoreCategory/*.h'
  s.source_files = 'CTImagePicker/*.{h,m}'

  s.frameworks   = 'Foundation', 'CoreGraphics', 'UIKit'
end
