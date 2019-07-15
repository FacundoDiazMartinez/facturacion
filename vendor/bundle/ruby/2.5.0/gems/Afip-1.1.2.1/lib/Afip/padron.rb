module Afip
	class Padron
		attr_reader :client, :body, :fault_code
		attr_accessor :dni, :tipo, :data
		def initialize(attrs = {})
			Afip::AuthData.environment = Afip.environment || :production
			url = Afip::AuthData.environment == :production ? "aws" : "awshomo"
			Afip.service_url = "https://#{url}.afip.gov.ar/sr-padron/webservices/personaServiceA4?WSDL"
			Afip.cuit ||= "20368642682"
			Afip.cert ||= "#{Afip.root}/lib/Afip/certs/desideral_prod.crt"
			Afip.pkey ||= "#{Afip.root}/lib/Afip/certs/desideral.key"
	      	Afip::AuthData.fetch("ws_sr_padron_a4")
	      	
	      	@client         = Savon.client(
		        ssl_cert_key_file: Afip.pkey,
		        ssl_cert_file: Afip.cert,
		        env_namespace: :soapenv,
		        namespace_identifier: :a4, 
		        encoding: 'UTF-8',
		        wsdl:  Afip.service_url
		    )

	      	@dni  = attrs[:dni].rjust(8, "0")
	      	@tipo = attrs[:tipo]
	      	@cuit = get_cuit
	  	end

	  	def get_persona
	  		body = setup_body

      		response = client.call(:get_persona,message: body)
      		rescue Savon::SOAPFault => error
		  	if !error.blank?
		  		@fault_code = error.to_hash[:fault][:faultstring]
		  	else
		  		@fault_code = nil
		  	end
		  	return response
	  	end

	  	def get_data
	  		@data = get_persona
	  		if fault_code.nil?
	  			set_data
	  		else
	  			return nil
	  		end
	  		
	  	end

	  	def set_data
	  		pp data.body
	  		if not data.body[:get_persona_response][:persona_return][:persona][:actividad].nil?
		  		{
		  			:last_name 		=> data.body[:get_persona_response][:persona_return][:persona][:apellido],
		  			:first_name 	=> data.body[:get_persona_response][:persona_return][:persona][:nombre],
		  			:cuit 			=> data.body[:get_persona_response][:persona_return][:persona][:id_persona],
		  			:cp 			=> data.body[:get_persona_response][:persona_return][:persona][:domicilio].last[:cod_postal],
		  			:address 		=> data.body[:get_persona_response][:persona_return][:persona][:domicilio].last[:direccion],
		  			:city_id 		=> data.body[:get_persona_response][:persona_return][:persona][:domicilio].last[:id_provincia],
		  			:city 			=> PROVINCIAS[data.body[:get_persona_response][:persona_return][:persona][:domicilio].last[:id_provincia]],
		  			:locality 		=> data.body[:get_persona_response][:persona_return][:persona][:domicilio].last[:localidad],
		  			:birthday		=> data.body[:get_persona_response][:persona_return][:persona][:fecha_nacimiento].to_date
		  		}
		  	else
		  		{
		  			:last_name 		=> Padron.divide_name(data.body[:get_persona_response][:persona_return][:persona][:apellido])[0],
		  			:first_name 	=> Padron.divide_name(data.body[:get_persona_response][:persona_return][:persona][:apellido])[1],
		  			:cuit 			=> data.body[:get_persona_response][:persona_return][:persona][:id_persona],
		  			:cp 			=> data.body[:get_persona_response][:persona_return][:persona].try(:[], :domicilio).try(:[], :cod_postal),
		  			:address 		=> data.body[:get_persona_response][:persona_return][:persona].try(:[], :domicilio).try(:[], :direccion),
		  			:city_id 		=> data.body[:get_persona_response][:persona_return][:persona].try(:[], :domicilio).try(:[], :id_provincia),
		  			:city 			=> PROVINCIAS[data.body[:get_persona_response][:persona_return][:persona].try(:[], :domicilio).try(:[], :id_provincia)],
		  			:locality 		=> data.body[:get_persona_response][:persona_return][:persona].try(:[], :domicilio).try(:[], :localidad),
		  			:birthday		=> data.body[:get_persona_response][:persona_return][:persona][:fecha_nacimiento].to_date
		  		}
		  	end
	  	end

	  	def self.divide_name(full_name)
	  		full_name = full_name.strip.split(/\s+/)
	        last_name = ''
	        last = (full_name.count / 2) - 1
	        (0..last).each do |i|
	          if i != last
	            last_name += full_name[i] + ' '
	          else
	            last_name += full_name[i]
	          end
	        end
	        full_name = full_name - (last_name.strip.split(/\s+/))
	        first_name = full_name.join(", ").gsub(",","").split.map(&:capitalize).join(' ')
	        last_name = last_name.split.map(&:capitalize).join(' ')
	        return [last_name, first_name]
	  	end

	  	def get_cuit
	  		if dni.length == 11
	  			@cuit = @dni
	  		else
	  			@cuit = calculate_cuit
	  		end
	  	end

	  	def calculate_cuit
	  		multiplicador = "2345672345"

	  		case tipo
	  		when "F"
	  			xy = 27
	  			xy_dni = "27#{dni}"
	  		when "M"
	  			xy = 20
	  			xy_dni = "20#{dni}"
	  		end
	  		verificador = 0
	  		(0..9).each do |i|
	  			verificador += (xy_dni.reverse[i].to_i * multiplicador[i].to_i)
	  		end
	  		verificador
	  		z = verificador - (verificador / 11 * 11)

	  		case z
	  		when 0
	  			z = 0
	  		when 1
	  			if tipo == "M"
	  				z = 9
	  				xy = 23
	  			elsif tipo == "F"
	  				z = 4
	  				xy = 23
	  			else
	  				z = 11 - z
	  			end
	  		else
	  			z = 11 - z
	  		end

	  		return "#{xy}#{dni}#{z}"
	  	end

	  	def setup_body
		  	body = {
		  		 'token' 				=> Afip::TOKEN,
		  		 'sign'  				=> Afip::SIGN,
		  		 'cuitRepresentada'		=> Afip.cuit,
		  		 'idPersona' 			=> @cuit.to_s
		  	}
		end

		PROVINCIAS = {
    		"0" => 'CIUDAD AUTONOMA BUENOS AIRES',
	    	"1" => 'BUENOS AIRES',
	    	"2" => 'CATAMARCA',
	    	"3" => 'CORDOBA',
	    	"4" => 'CORRIENTES',
	    	"5" => 'ENTRE RIOS',
	    	"6" => 'JUJUY',
	    	"7" => 'MENDOZA',
	    	"8" => 'LA RIOJA',
	    	"9" => 'SALTA',
	    	"10" => 'SAN JUAN',
	    	"11" => 'SAN LUIS',
	    	"12" => 'SANTA FE',
	    	"13" => 'SANTIAGO DEL ESTERO',
	    	"14" => 'TUCUMAN',
	    	"16" => 'CHACO', 
	    	"17" => 'CHUBUT',
	    	"18" => 'FORMOSA',
	    	"19" => 'MISIONES',
	    	"20" => 'NEUQUEN',
	    	"21" => 'LA PAMPA',
	    	"22" => 'RIO NEGRO',
	    	"23" => 'SANTA CRUZ',
	    	"24" => 'TIERRA DEL FUEGO'
    }
	end
end




