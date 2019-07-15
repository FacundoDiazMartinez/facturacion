# -*- encoding: utf-8 -*-
# stub: bootstrap-toggle-rails 2.2.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "bootstrap-toggle-rails".freeze
  s.version = "2.2.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Raphael Kallensee".freeze]
  s.bindir = "exe".freeze
  s.date = "2016-01-11"
  s.description = "Bootstrap Toggle is a highly flexible Bootstrap plugin that converts checkboxes into toggles.".freeze
  s.email = ["raphael@kallensee.name".freeze]
  s.homepage = "https://github.com/rkallensee/bootstrap-toggle-rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "Bootstrap Toggle (unofficial) plugin for the Rails asset pipeline".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.10"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.10"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.10"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
  end
end
