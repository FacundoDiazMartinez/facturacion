module Afip
  class CTG
    attr_reader :client, :base_imp, :total
    attr_accessor :ctg_num, :cp_num, :cod_especie, :cuit_canjeador,:rccc, :cuit_destino, :cuit_destinatario, :localidad_origen, :localidad_destino,
                  :cosecha, :peso, :cuit_transportista, :horas, :patente, :km, :cuit_corredor, :remitente_com, :body

    def initialize(attrs = {})
      Afip::AuthData.fetch("wsctg")
      @client         = Savon.client(
        ssl_cert_key_file: Afip.pkey,
        ssl_cert_file: Afip.cert,
        env_namespace: :soapenv,
        namespace_identifier: :ctg,
        log: true,
        logger: Rails.logger,
        log_level: :debug,
        pretty_print_xml: true,
        encoding: 'UTF-8',
        ssl_version: :TLSv1,
        wsdl:  Afip.service_url
      )

      @ctg_num                = attrs[:ctg_num]
      @cp_num                 = attrs[:cp_num]
      @cod_especie            = attrs[:cod_especie]
      @cuit_canjeador         = attrs[:cuit_canjeador]
      @rccc                   = attrs[:rccc]
      @cuit_destino           = attrs[:cuit_destino]
      @cuit_destinatario      = attrs[:cuit_destinatario]
      @localidad_origen       = attrs[:localidad_origen]
      @localidad_destino      = attrs[:localidad_destino]
      @cosecha                = attrs[:cosecha]
      @peso                   = attrs[:peso]
      @cuit_transportista     = attrs[:cuit_transportista]
      @horas                  = attrs[:horas]
      @patente                = attrs[:patente]
      @km                     = attrs[:km]
      @cuit_corredor          = attrs[:cuit_corredor]
      @remitente_com          = attrs[:remitente_com]
      @cuit_chofer            = attrs[:cuit_chofer]
      @cant_kilos_carta_porte = attrs[:cant_kilos_carta_porte]
      @establecimiento        = attrs[:establecimiento]
      @cuit_solicitante       = attrs[:cuit_solicitante]
      @fecha_desde            = attrs[:fecha_desde]
      @fecha_hasta            = attrs[:fecha_hasta]

      @body               = {"request" =>{"auth" => Afip.auth_hash("wsctg")}}
    end

    def solicitar_ctg_inicial
      pp body = setup_ctg

      pp response = client.call(:solicitar_ctg_inicial,message: body)

      setup_response(response.to_hash)

      self.authorized?
    end

    def setup_ctg

      datos = {
                  "datosSolicitarCTGInicial" =>{
                      "cartaPorte"                        => @cp_num, #long
                      "codigoEspecie"                     => @cod_especie, #int
                      #"cuitCanjeador"                     => @cuit_canjeador.to_i, #long
                      #"remitenteComercialComoCanjeador"   => @rccc,
                      "cuitDestino"                       => @cuit_destino, #long
                      "cuitDestinatario"                  => @cuit_destinatario, #long
                      "codigoLocalidadOrigen"             => @localidad_origen, #int
                      "codigoLocalidadDestino"            => @localidad_destino, #int
                      "codigoCosecha"                     => @cosecha, #string
                      "pesoNeto"                          => @peso.to_i, #long
                      #"cuitTransportista"                 => @cuit_transportista.to_i, #long
                      #"cantHoras"                         => @horas, #int
                      #"patente"                           => @patente, #string
                      "kmARecorrer"                       => @km, #unsignedint
                      #"cuitCorredor"                      => @cuit_corredor.to_i, #long
                      #"remitenteComercialcomoProductor"   => @remitente_com
                    }
                }

      @body["request"].merge!(datos)
      return @body
    end

    def authorized?
        !response.nil?
    end

    def anular_ctg
      request = {
                  "datosAnularCTG" =>{
                    "cartaPorte"  => @cp_num,
                    "ctg"         => @ctg_num
                  }
                }
      body["request"].merge(request)

      response = client.call(:anular_ctg, message: body)
    end

    def cambiar_destino_detinatario_ctg_rechazado
      request = {
                  "datosCambiarDestinoDestinatarioCTGRechazado" =>{
                    "cartaPorte"                  => @cp_num,
                    "ctg"                         => @ctg_num,
                    "codigoLocalidadDestino"      => @destino,
                    "codigoLocalidadDestinatario" => @destinatario,
                    "kmARecorrer"                 => @km
                  }
                }
      body["request"].merge(request)

      response = client.call(:cambiar_destino_detinatario_ctg_rechazado, message: body)
    end

    def confirmar_arribo
      request = {
                  "datosConfirmarArribo" =>{
                    "cartaPorte"          => @cp_num,
                    "ctg"                 => @ctg_num,
                    "cuitTransportista"   => @cuit_transportista,
                    "cuitChofer"          => @cuit_chofer,
                    "cantKilosCartaPorte" => @cant_kilos_carta_porte
                  }
                }
      body["request"].merge(request)

      response = client.call(:confirmar_arribo, message: body)
    end

    def confirmar_definitivo
      request = {
                  "datosConfirmarDefinitivo" =>{
                    "cartaPorte"          => @cp_num,
                    "ctg"                 => @ctg_num,
                    "establecimiento"     => @establecimiento,
                    "codigoCosecha"       => @cosecha,
                    "pesoNeto"            => @peso
                  }
                }
      body["request"].merge(request)

      response = client.call(:confirmar_definitivo, message: body)
    end

    def consultar_cosechas
      pp "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
      response = client.call(:obtener_cosechas, message: body)
      return response["arrayCosechas"]
    end

    def consultar_constancia_ctg_pdf
      request = {
                  "ctg" => @ctg_num
                }

      body["request"].merge(request)

      response = client.call(:consultar_constancia_ctgpdf, message: body)
    end

    def consultar_ctg
      request = {
                  "consultarCTGDatos" =>{
                    "cartaPorte"          => @cp_num,
                    "ctg"                 => @ctg_num,
                    "patente"             => @patente,
                    "cuitSolicitante"     => @cuit_solicitante,
                    "cuitDestino"         => @destino,
                    "fechaEmisionDesde"   => @fecha_desde,
                    "fechaEmisionHsta"    => @fecha_hasta,
                    "cuitCorredor"        => @cuit_corredor
                  }
                }
      body["request"].merge(request)

      response = client.call(:consultar_ctg, message: body)
    end

    def consultar_ctg_rechazados
      response = client.call(:consultar_ctg_rechazados, message: body)
      return response.to_hash["response"]["arrayConsultarCTGRechazados"]
    end

    def consultar_detalle_ctg
      request = {
                  "ctg" => @ctg_num
                }

      body["request"].merge(request)

      response = client.call(:consultar_constancia_ctg_pdf, message: body)
      return response.to_hash["response"]["consultarDetalleCTGDatos"]
    end

    def consultar_especies
      response = client.call(:consultar_especies, message: body)
      response.body[:consultar_especies_response][:response][:array_especies][:especie].map{|c| [c[:codigo],c[:descripcion]]}
    end

    def consultar_establecimientos
      response = client.call(:consultar_establecimientos, message: body)
      response.body[:consultar_especies_response][:response][:array_establecimientos][:establecimiento].map{|c| [c]}
    end

    def consultar_provincias
      response = client.call(:consultar_provincias, message: body)
      response.body[:consultar_provincias_response][:consultar_provincias_response][:array_provincias][:provincia].map{|c| [c[:codigo],c[:descripcion]]}
    end

    def consultar_cosechas
      response = client.call(:consultar_cosechas, message: body)
      response.body[:consultar_cosechas_response][:response][:array_cosechas][:cosecha].map{|c| [c[:codigo],c[:descripcion]]}
    end

    def consultar_localidades(city)
      body["request"]["codigoProvincia"] = city
      response = client.call(:consultar_localidades_por_provincia, message: body)
      if response.body[:consultar_localidades_por_provincia_response][:response][:array_localidades][:localidad].class.name != "Array"
        [response.body[:consultar_localidades_por_provincia_response][:response][:array_localidades][:localidad]].map{|c| [c[:codigo],c[:descripcion]]}
      else
        response.body[:consultar_localidades_por_provincia_response][:response][:array_localidades][:localidad].map{|c| [c[:codigo],c[:descripcion]]}
      end
    end

    private

    def setup_response(response)
      # TODO: turn this into an all-purpose Response class
      pp response
    end
  end
end
