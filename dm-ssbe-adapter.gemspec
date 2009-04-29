# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dm-ssbe-adapter}
  s.version = "0.10.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Paul Sadauskas"]
  s.date = %q{2009-04-29}
  s.email = %q{psadauskas@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.mkd"
  ]
  s.files = [
    "LICENSE",
    "README.mkd",
    "Rakefile",
    "VERSION.yml",
    "lib/dm-ssbe-adapter.rb",
    "lib/dm-ssbe-adapter/service.rb",
    "lib/dm-ssbe-adapter/service_descriptors.rb",
    "lib/dm-ssbe-adapter/ssbe_authenticator.rb",
    "lib/dm-types/href.rb",
    "test/dm_ssbe_adapter_test.rb",
    "test/test_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/absperf/dm-ssbe-adapter}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A DataMapper adapter for System Shepherd flavored REST services}
  s.test_files = [
    "test/test_helper.rb",
    "test/dm_ssbe_adapter_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<dm-core>, ["~> 0.10.0"])
      s.add_runtime_dependency(%q<resourceful>, ["~> 0.3.0"])
      s.add_runtime_dependency(%q<extlib>, ["~> 0.10.0"])
      s.add_runtime_dependency(%q<json>, ["~> 1.1.0"])
    else
      s.add_dependency(%q<dm-core>, ["~> 0.10.0"])
      s.add_dependency(%q<resourceful>, ["~> 0.3.0"])
      s.add_dependency(%q<extlib>, ["~> 0.10.0"])
      s.add_dependency(%q<json>, ["~> 1.1.0"])
    end
  else
    s.add_dependency(%q<dm-core>, ["~> 0.10.0"])
    s.add_dependency(%q<resourceful>, ["~> 0.3.0"])
    s.add_dependency(%q<extlib>, ["~> 0.10.0"])
    s.add_dependency(%q<json>, ["~> 1.1.0"])
  end
end
