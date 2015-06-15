# -*- encoding: utf-8 -*-
# stub: activeadmin 1.0.0.pre1 ruby lib

Gem::Specification.new do |s|
  s.name = "activeadmin"
  s.version = "1.0.0.pre1"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Greg Bell"]
  s.date = "2015-03-12"
  s.description = "The administration framework for Ruby on Rails."
  s.email = ["gregdbell@gmail.com"]
  s.homepage = "http://activeadmin.info"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "The administration framework for Ruby on Rails."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<arbre>, [">= 1.0.2", "~> 1.0"])
      s.add_runtime_dependency(%q<bourbon>, [">= 0"])
      s.add_runtime_dependency(%q<coffee-rails>, [">= 0"])
      s.add_runtime_dependency(%q<formtastic>, ["~> 3.1"])
      s.add_runtime_dependency(%q<formtastic_i18n>, [">= 0"])
      s.add_runtime_dependency(%q<inherited_resources>, ["~> 1.6"])
      s.add_runtime_dependency(%q<jquery-rails>, [">= 0"])
      s.add_runtime_dependency(%q<jquery-ui-rails>, ["~> 5.0"])
      s.add_runtime_dependency(%q<kaminari>, ["~> 0.15"])
      s.add_runtime_dependency(%q<rails>, ["< 5.0", ">= 3.2"])
      s.add_runtime_dependency(%q<ransack>, ["~> 1.3"])
      s.add_runtime_dependency(%q<sass-rails>, [">= 0"])
    else
      s.add_dependency(%q<arbre>, [">= 1.0.2", "~> 1.0"])
      s.add_dependency(%q<bourbon>, [">= 0"])
      s.add_dependency(%q<coffee-rails>, [">= 0"])
      s.add_dependency(%q<formtastic>, ["~> 3.1"])
      s.add_dependency(%q<formtastic_i18n>, [">= 0"])
      s.add_dependency(%q<inherited_resources>, ["~> 1.6"])
      s.add_dependency(%q<jquery-rails>, [">= 0"])
      s.add_dependency(%q<jquery-ui-rails>, ["~> 5.0"])
      s.add_dependency(%q<kaminari>, ["~> 0.15"])
      s.add_dependency(%q<rails>, ["< 5.0", ">= 3.2"])
      s.add_dependency(%q<ransack>, ["~> 1.3"])
      s.add_dependency(%q<sass-rails>, [">= 0"])
    end
  else
    s.add_dependency(%q<arbre>, [">= 1.0.2", "~> 1.0"])
    s.add_dependency(%q<bourbon>, [">= 0"])
    s.add_dependency(%q<coffee-rails>, [">= 0"])
    s.add_dependency(%q<formtastic>, ["~> 3.1"])
    s.add_dependency(%q<formtastic_i18n>, [">= 0"])
    s.add_dependency(%q<inherited_resources>, ["~> 1.6"])
    s.add_dependency(%q<jquery-rails>, [">= 0"])
    s.add_dependency(%q<jquery-ui-rails>, ["~> 5.0"])
    s.add_dependency(%q<kaminari>, ["~> 0.15"])
    s.add_dependency(%q<rails>, ["< 5.0", ">= 3.2"])
    s.add_dependency(%q<ransack>, ["~> 1.3"])
    s.add_dependency(%q<sass-rails>, [">= 0"])
  end
end
