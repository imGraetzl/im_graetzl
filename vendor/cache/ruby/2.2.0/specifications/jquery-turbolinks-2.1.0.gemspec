# -*- encoding: utf-8 -*-
# stub: jquery-turbolinks 2.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "jquery-turbolinks"
  s.version = "2.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Sasha Koss"]
  s.date = "2014-08-29"
  s.description = "jQuery plugin for drop-in fix binded events problem caused by Turbolinks"
  s.email = "koss@nocorp.me"
  s.homepage = "https://github.com/kossnocorp/jquery.turbolinks"
  s.licenses = ["MIT"]
  s.rubyforge_project = "jquery-turbolinks"
  s.rubygems_version = "2.4.8"
  s.summary = "jQuery plugin for drop-in fix binded events problem caused by Turbolinks"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>, [">= 3.1.0"])
      s.add_runtime_dependency(%q<turbolinks>, [">= 0"])
    else
      s.add_dependency(%q<railties>, [">= 3.1.0"])
      s.add_dependency(%q<turbolinks>, [">= 0"])
    end
  else
    s.add_dependency(%q<railties>, [">= 3.1.0"])
    s.add_dependency(%q<turbolinks>, [">= 0"])
  end
end
