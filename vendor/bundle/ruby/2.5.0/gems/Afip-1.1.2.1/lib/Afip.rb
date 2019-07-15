require "Afip/version"
require "bundler/setup"
require "Afip/constants"
require "savon"
require "Afip/core_ext/float"
require "Afip/core_ext/hash"
require "Afip/core_ext/string"

require 'net/http'
require 'net/https'

#require 'net/http'
require 'net/https'
module Afip

  class NullOrInvalidAttribute < StandardError; end

  def self.root
    File.expand_path '../..', __FILE__
  end

  autoload :Authorizer,   "Afip/authorizer"
  autoload :AuthData,     "Afip/auth_data"
  autoload :Padron,       "Afip/padron"
  autoload :Wsaa,         "Afip/wsaa"
  autoload :Bill,         "Afip/bill"
  autoload :CTG,          "Afip/ctg"


  class << self
      mattr_accessor :cuit, :pkey, :cert, :environment, :openssl_bin,
                     :default_concepto, :default_documento, :default_moneda, :own_iva_cond, :service_url, :auth_url
  end

  def self.setup(&block)
      yield self
  end

  extend self

  def auth_hash(service = "wsfe")
    case service
    when "wsfe"
      { 'Token' => Afip::TOKEN, 'Sign'  => Afip::SIGN, 'Cuit'  => Afip.cuit }
    when "ws_sr_padron_a4"
      { 'token' => Afip::TOKEN, 'sign'  => Afip::SIGN, 'cuitRepresentado'  => Afip.cuit }
    when "wsctg"
      { 'token' => Afip::TOKEN, 'sign'  => Afip::SIGN, 'cuitRepresentado'  => Afip.cuit }
    end
  end

  def log?
    Afip.verbose || ENV["VERBOSE"]
  end
  
  def deleteToken
      AuthData.deleteToken
  end
end