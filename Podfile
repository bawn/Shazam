# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'
inhibit_all_warnings!
workspace './Shazam.xcworkspace'

target 'Shazam' do
    project './Shazam'
  use_frameworks!

end

target 'Shazam-Demo' do
    project './Shazam-Demo'
    use_frameworks!
    pod 'SnapKit'
    pod 'MJRefresh'
    pod 'Trident'
    pod 'Reveal-SDK',    '22', :configurations => ['Debug']
end
