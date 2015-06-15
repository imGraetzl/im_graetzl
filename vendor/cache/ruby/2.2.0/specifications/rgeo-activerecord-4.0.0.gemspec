# -*- encoding: utf-8 -*-
# stub: rgeo-activerecord 4.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rgeo-activerecord"
  s.version = "4.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Daniel Azuma, Tee Parham"]
  s.date = "2015-05-24"
  s.description = "RGeo is a geospatial data library for Ruby. RGeo::ActiveRecord is an optional RGeo module providing some spatial extensions to ActiveRecord, as well as common tools used by RGeo-based spatial adapters."
  s.email = "dazuma@gmail.com, parhameter@gmail.com"
  s.homepage = "http://github.com/rgeo/rgeo-activerecord"
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.rubygems_version = "2.4.8"
  s.summary = "An RGeo module providing spatial extensions to ActiveRecord."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rgeo>, ["~> 0.3"])
      s.add_runtime_dependency(%q<activerecord>, ["~> 4.2"])
      s.add_development_dependency(%q<minitest>, ["~> 5.4"])
      s.add_development_dependency(%q<rake>, ["~> 10.4"])
      s.add_development_dependency(%q<mocha>, ["~> 1.1"])
    else
      s.add_dependency(%q<rgeo>, ["~> 0.3"])
      s.add_dependency(%q<activerecord>, ["~> 4.2"])
      s.add_dependency(%q<minitest>, ["~> 5.4"])
      s.add_dependency(%q<rake>, ["~> 10.4"])
      s.add_dependency(%q<mocha>, ["~> 1.1"])
    end
  else
    s.add_dependency(%q<rgeo>, ["~> 0.3"])
    s.add_dependency(%q<activerecord>, ["~> 4.2"])
    s.add_dependency(%q<minitest>, ["~> 5.4"])
    s.add_dependency(%q<rake>, ["~> 10.4"])
    s.add_dependency(%q<mocha>, ["~> 1.1"])
  end
end
