# -*- encoding: utf-8 -*-
# stub: activerecord-postgis-adapter 3.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "activerecord-postgis-adapter"
  s.version = "3.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Daniel Azuma, Tee Parham"]
  s.date = "2015-05-25"
  s.description = "ActiveRecord connection adapter for PostGIS. It is based on the stock PostgreSQL adapter, and adds built-in support for the spatial extensions provided by PostGIS. It uses the RGeo library to represent spatial data in Ruby."
  s.email = "dazuma@gmail.com, parhameter@gmail.com"
  s.homepage = "http://github.com/rgeo/activerecord-postgis-adapter"
  s.licenses = ["BSD"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.rubygems_version = "2.4.8"
  s.summary = "ActiveRecord adapter for PostGIS, based on RGeo."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, ["~> 4.2"])
      s.add_runtime_dependency(%q<rgeo-activerecord>, ["~> 4.0"])
      s.add_development_dependency(%q<rake>, ["~> 10.3"])
      s.add_development_dependency(%q<minitest>, ["~> 5.4"])
      s.add_development_dependency(%q<mocha>, ["~> 1.1"])
      s.add_development_dependency(%q<appraisal>, ["~> 1.0"])
    else
      s.add_dependency(%q<activerecord>, ["~> 4.2"])
      s.add_dependency(%q<rgeo-activerecord>, ["~> 4.0"])
      s.add_dependency(%q<rake>, ["~> 10.3"])
      s.add_dependency(%q<minitest>, ["~> 5.4"])
      s.add_dependency(%q<mocha>, ["~> 1.1"])
      s.add_dependency(%q<appraisal>, ["~> 1.0"])
    end
  else
    s.add_dependency(%q<activerecord>, ["~> 4.2"])
    s.add_dependency(%q<rgeo-activerecord>, ["~> 4.0"])
    s.add_dependency(%q<rake>, ["~> 10.3"])
    s.add_dependency(%q<minitest>, ["~> 5.4"])
    s.add_dependency(%q<mocha>, ["~> 1.1"])
    s.add_dependency(%q<appraisal>, ["~> 1.0"])
  end
end
