module Afip

  # This class handles authorization data
  #
  class AuthData

    class << self

      attr_accessor :environment, :todays_data_file_name

      # Fetches WSAA Authorization Data to build the datafile for the day.
      # It requires the private key file and the certificate to exist and
      # to be configured as Afip.pkey and Afip.cert
      #
      def fetch(service = "wsfe")
        unless File.exists?(Afip.pkey)
          raise "Archivo de llave privada no encontrado en #{ Afip.pkey }"
        end

        unless File.exists?(Afip.cert)
          raise "Archivo certificado no encontrado en #{ Afip.cert }"
        end

        unless File.exists?(todays_data_file_name)
          Afip::Wsaa.login(service)
        end

        YAML.load_file(todays_data_file_name).each do |k, v|
          Afip.const_set(k.to_s.upcase, v) #unless Afip.const_defined?(k.to_s.upcase)
        end
      end

      # Returns the authorization hash, containing the Token, Signature and Cuit
      # @return [Hash]
      #
      def auth_hash(service = "wsfe")
        fetch unless Afip.constants.include?(:TOKEN) && Afip.constants.include?(:SIGN)
        case service
        when "wsfe"
          { 'Token' => Afip::TOKEN, 'Sign'  => Afip::SIGN, 'Cuit'  => Afip.cuit }
        when "ws_sr_padron_a4"
          { 'token' => Afip::TOKEN, 'sign'  => Afip::SIGN, 'cuitRepresentado'  => Afip.cuit }
        when "wsctg"
          { 'token' => Afip::TOKEN, 'sign'  => Afip::SIGN, 'cuitRepresentado'  => Afip.cuit }
        end
      end

      # Returns the right wsaa url for the specific environment
      # @return [String]
      #
      def wsaa_url
        Afip::URLS[Afip.environment][:wsaa]
      end

      # Returns the right wsfe url for the specific environment
      # @return [String]
      #
      def wsfe_url
        raise 'Environment not sent to either :test or :production' unless Afip::URLS.keys.include? environment
        Afip::URLS[Afip.environment][:wsfe]
      end

      # Creates the data file name for a cuit number and the current day
      # @return [String]
      #
      def todays_data_file_name
        "#{Rails.root}/afip/#{environment.to_s}_Afip_#{ Afip.cuit }_#{ Time.new.strftime('%Y_%m_%d') }.yml"
      end
    end
  end
end