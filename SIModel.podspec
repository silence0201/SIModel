Pod::Spec.new do |s|
  s.name         = "SIModel"
  s.version      = "1.0"
  s.summary      = "JSON To Model"
  s.description  = <<-DESC
                      A Way  JSON To Model
                   DESC

  s.homepage     = "https://github.com/silence0201/SIModel"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Silence" => "374619540@qq.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/silence0201/SIModel.git", :tag => "1.0" }
  s.source_files  = "SIModel", "SIModel/**/*.{h,m}"
  s.exclude_files = "SIModel/Exclude"
  s.public_header_files = "SIModel/**/*.h"
  s.requires_arc = true
end
