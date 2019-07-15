module Afip
  # Authorization class. Handles interactions wiht the WSAA, to provide
  # valid key and signature that will last for a day.
  #
  class Wsaa
    # Main method for authentication and authorization.
    # When successful, produces the yaml file with auth data.
    #
    def self.login(service = "wsfe")
      tra   = build_tra(service)
      cms   = build_cms(tra)
      req   = build_request(cms)
      auth  = call_wsaa(req)

      write_yaml(auth)
    end

    protected
    # Builds the xml for the 'Ticket de Requerimiento de Acceso'
    # @return [String] containing the request body
    #
    def self.build_tra service
      @now = (Time.now) - 120
      @from = @now.strftime('%FT%T%:z')
      @to   = (@from.to_time.end_of_day).strftime('%FT%T%:z')
      @id   = @now.strftime('%s')
      tra  = <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<loginTicketRequest version="1.0">
  <header>
    <uniqueId>#{ @id }</uniqueId>
    <generationTime>#{ @from }</generationTime>
    <expirationTime>#{ @to }</expirationTime>
  </header>
  <service>#{service}</service>
</loginTicketRequest>
EOF
      return tra
    end

    # Builds the CMS
    # @return [String] cms
    #
    def self.build_cms(tra)
      cms = `echo '#{ tra }' |
        #{ Afip.openssl_bin } cms -sign -in /dev/stdin -signer #{ Afip.cert } -inkey #{ Afip.pkey } -nodetach \
                -outform der |
        #{ Afip.openssl_bin } base64 -e`
      return cms
    end

    # Builds the CMS request to log in to the server
    # @return [String] the cms body
    #
    def self.build_request(cms)
      request = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://wsaa.view.sua.dvadac.desein.afip.gov">
  <SOAP-ENV:Body>
    <ns1:loginCms>
      <ns1:in0>
#{ cms }
      </ns1:in0>
    </ns1:loginCms>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
XML
      return request
    end

    # Calls the WSAA with the request built by build_request
    # @return [Array] with the token and signature
    #
    def self.call_wsaa(req)
      response = `echo '#{ req }' | curl -k -s -H 'Content-Type: application/soap+xml; action=""' -d @- #{ Afip::AuthData.wsaa_url }`
      pp response
      response = CGI::unescapeHTML(response)
      token = response.scan(/\<token\>(.+)\<\/token\>/).first.first
      sign  = response.scan(/\<sign\>(.+)\<\/sign\>/).first.first
      return [token, sign]
    end

    # Writes the token and signature to a YAML file in the /tmp directory
    #
    def self.write_yaml(certs)
      yml = <<-YML
      token: #{certs[0]}
      sign: #{certs[1]}
      YML
    `echo '#{ yml }' > #{Rails.root}/afip/#{Afip::AuthData.environment.to_s}_Afip_#{ Afip.cuit }_#{ Time.new.strftime('%Y_%m_%d') }.yml`
    end

  end
end
