lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'fluent-plugin-raygun'
  spec.version       = '0.1.0'
  spec.authors       = ['Taylor Lodge']
  spec.email         = ['taylor@raygun.io']

  spec.summary       = 'Fluentd output plugin that sends aggregated errors/exception events to Raygun. Raygun is a error logging and aggregation platform.'
  spec.description = spec.summary
  spec.homepage      = 'https://github.com/mindscapehq/fluent-plugin-raygun'
  spec.license       = 'MIT License'

  test_files, files  = `git ls-files -z`.split("\x0").partition do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.files         = files
  spec.executables   = files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = test_files
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'test-unit'

  spec.add_development_dependency 'byebug'

  spec.add_runtime_dependency     'fluentd'
end
