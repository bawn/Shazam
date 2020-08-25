Pod::Spec.new do |s|
  s.name             = "Shazam"
  s.version          = "0.0.8"
  s.summary          = "An easy solution to nested scrolling"
  s.homepage         = "https://github.com/bawn/Shazam"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.authors          = { "bawn" => "lc5491137@gmail.com" }
  s.swift_version    = "4.2"
  s.source           = { :git => "https://github.com/bawn/Shazam.git", :tag => s.version.to_s }
  s.platform         = :ios, '9.0'
  s.requires_arc     = true
  s.source_files     = ["Shazam/*.swift", "Shazam/Shazam.h"]
end
