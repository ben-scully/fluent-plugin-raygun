# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-raygun"
  spec.version       = "0.0.1"
  spec.authors       = ["John-Daniel Trask"]
  spec.email         = ["traskjd@gmail.com"]
  spec.summary       = %q{Fluentd output plugin that sends aggregated errors/exception events to Raygun. Raygun is a error logging and aggregation platform.}
  spec.homepage      = "https://github.com/mindscapehq/fluent-plugin-raygun"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "test-unit", ">= 3.1.0"
  spec.add_development_dependency "appraisal"

  # Since Fluentd v0.14 requires ruby 2.1 or later.
  if defined?(RUBY_VERSION) && RUBY_VERSION < "2.1"
    spec.add_runtime_dependency "fluentd", "< 0.14"
  else
    spec.add_runtime_dependency "fluentd"
  end
  spec.add_runtime_dependency "raygun4ruby", "~> 2.7.0"
end
