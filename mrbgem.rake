MRuby::Gem::Specification.new('mruby-reeves') do |spec|
  spec.license = 'MIT'
  spec.authors = 'Yusuke Sangenya'
  spec.add_dependency 'mruby-shelf', github: 'genya0407/mruby-shelf'
  spec.add_dependency 'mruby-simplehttpserver'
  spec.add_dependency 'mruby-regexp-pcre'
  spec.add_dependency 'mruby-erb'
  spec.add_dependency 'mruby-json'
  spec.add_dependency "mruby-hash-ext"
  spec.add_dependency "mruby-enumerator"
  spec.add_dependency 'mruby-proc-ext'

  spec.add_test_dependency 'mruby-tempfile'
end
