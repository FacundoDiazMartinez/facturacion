# -*- encoding: utf-8 -*-
# stub: Afip 1.1.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "Afip".freeze
  s.version = "1.1.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Facundo A. D\u00EDaz Mart\u00EDnez".freeze]
  s.bindir = "exe".freeze
  s.date = "2019-04-30"
  s.description = "Gema para la comunicacion con los Web Services de AFIP.".freeze
  s.email = ["facundo_diaz_martinez@hotmail.com".freeze]
  s.homepage = "http://litecode.com.ar/".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "Comunicacion con AFIP".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<savon>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<httpi>.freeze, [">= 0"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.16"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
    else
      s.add_dependency(%q<savon>.freeze, [">= 0"])
      s.add_dependency(%q<httpi>.freeze, [">= 0"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.16"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    end
  else
    s.add_dependency(%q<savon>.freeze, [">= 0"])
    s.add_dependency(%q<httpi>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.16"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
  end
end
