MRuby::Gem::Specification.new('reeves') do |spec|
  spec.license = 'MIT'
  spec.authors = 'Yusuke Sangenya'
  spec.add_dependency 'mruby-shelf', github: 'genya0407/mruby-shelf'
  spec.add_dependency 'mruby-simplehttpserver', github: 'genya0407/mruby-simplehttpserver'
  spec.add_dependency 'mruby-regexp-pcre'
  spec.add_dependency 'mruby-erb', github: 'genya0407/mruby-erb'
  spec.add_dependency 'mruby-json'
  spec.add_dependency 'mruby-uri-parser'
  spec.add_dependency 'mruby-tempfile'
end
