module Afip
  class Authorizer
    attr_reader :pkey, :cert

    def initialize
      @pkey = Afip.pkey
      @cert = Afip.cert
    end
  end
end