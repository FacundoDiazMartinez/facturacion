module Afip
	class Bill
		attr_reader   :cbte_type, :body, :response, :fecha_emision, :total, :client
		attr_accessor :net, :doc_num, :iva_cond, :documento, :concepto, :moneda, :cbte_type,
                  	  :due_date, :fch_serv_desde, :fch_serv_hasta, :fch_emision,
                      :ivas, :sale_point, :cant_reg, :no_gravado, :gravado, :exento, :otros_imp, :tributos

		def initialize(attrs={})
			@client = Bill.set_client
			@sale_point			= attrs[:sale_point]
		    @body					= { "Auth" => Afip.auth_hash }
		    @net					= attrs[:net] 			|| 0.0
		    @documento 		= attrs[:documento] 	|| Afip.default_documento
		    @moneda 			= attrs[:moneda]    	|| Afip.default_moneda
		    @iva_cond 		= attrs[:iva_cond]
		    @concepto 		= attrs[:concepto]  	|| Afip.default_concepto
		    @ivas 				= attrs[:ivas] 			|| Array.new # [ 1, 100.00, 10.50 ], [ 2, 100.00, 21.00 ]
		    @fecha_emision 	= attrs[:fch_emision] 	|| Time.new
		    @fch_serv_hasta = attrs[:fch_serv_hasta]
		    @fch_serv_desde = attrs[:fch_serv_desde]
		    @due_date 		= attrs[:due_date]
		    @cbte_type 		= attrs[:cbte_type]
		    @cant_reg 		= attrs[:cant_reg] 		|| 1
		    @no_gravado 	= attrs[:no_gravado] 	|| 0.0
		    @gravado 			= attrs[:gravado] 		|| 0.0
		    @exento 			= attrs[:exento] 		|| 0.0
		    @otros_imp 		= attrs[:otros_imp] 	|| 0.0
		    @total 				= net.to_f + iva_sum.to_f + exento.to_f  + no_gravado.to_f + otros_imp.to_f
		    @tributos 		= attrs[:tributos] 		|| []
		end

		def self.get_ptos_vta
			client 	 = set_client
			body	 = { "Auth" => Afip.auth_hash }
			response = client.call(:fe_param_get_ptos_venta, message: body)
			if response.body[:fe_param_get_ptos_venta_response][:fe_param_get_ptos_venta_result][:errors].nil?
				if response.body[:fe_param_get_ptos_venta_response][:fe_param_get_ptos_venta_result][:result_get][:pto_venta].is_a?(Hash)
					response.body[:fe_param_get_ptos_venta_response][:fe_param_get_ptos_venta_result][:result_get][:pto_venta][:nro]
				else
					response.body[:fe_param_get_ptos_venta_response][:fe_param_get_ptos_venta_result][:result_get][:pto_venta].map{|r| r[:nro]}
				end
			else
				[]
			end
		end

		def self.get_tributos
			client 		= set_client
			body 		= { "Auth" => Afip.auth_hash }
			response 	= client.call(:fe_param_get_tipos_tributos, message: body)
			if response.body[:fe_param_get_tipos_tributos_response][:fe_param_get_tipos_tributos_result][:errors].nil?
				response.body[:fe_param_get_tipos_tributos_response][:fe_param_get_tipos_tributos_result][:result_get][:tributo_tipo]
			else
				[]
			end
		end

		def self.set_client
			Afip::AuthData.fetch
			@client = Savon.client(
		        wsdl:  Afip.service_url,
		        namespaces: { "xmlns" => "http://ar.gov.afip.dif.FEV1/" },
		        log_level:  :debug,
		        ssl_cert_key_file: Afip.pkey,
		        ssl_cert_file: Afip.cert,
		        ssl_verify_mode: :none,
		        read_timeout: 90,
		        open_timeout: 90,
		        headers: { "Accept-Encoding" => "gzip, deflate", "Connection" => "Keep-Alive" }
		    )
		end

		def authorize
	      	body 	  = setup_bill
	      	pp response  = client.call(:fecae_solicitar, message: body)
		  		setup_response(response.to_hash)
	      	authorized?
	    end

	    def setup_bill
	      	array_ivas = {}
					array_ivas["AlicIva"] = ivas.map{ |i| { "Id" => i[0], "BaseImp" => i[1].round(2), "Importe" => i[2].round(2)} unless ["01", "02"].include?(i[0])}.compact

	      	array_tributos = {}
					array_tributos["Tributo"] =  tributos.map{ |t|
						if t[1].blank?
							{
		      			"Id" => t[0],
		      			"BaseImp" => t[2].to_f.round(2),
		      			"Alic" => t[3].to_f.round(2),
		      			"Importe" => t[4].to_f.round(2)
		      		}
						else
							{
		      			"Id" => t[0],
		      			"Desc" => t[1],
		      			"BaseImp" => t[2].to_f.round(2),
		      			"Alic" => t[3].to_f.round(2),
		      			"Importe" => t[4].to_f.round(2)
		      		}
						end
	      	}

	        fecaereq = {
	        	"FeCAEReq" => {
	                "FeCabReq" => Afip::Bill.header(cant_reg, cbte_type, sale_point),
	                "FeDetReq" => {
                      	"FECAEDetRequest" => {
	                        "Concepto"    => Afip::CONCEPTOS[concepto],
	                        "DocTipo"     => Afip::DOCUMENTOS[documento],
	                        "DocNro"	  => doc_num,
	                        "CbteFch"     => fecha_emision.strftime('%Y%m%d'),
	                        "ImpTotConc"  => no_gravado,
	                        "ImpNeto"	  => net.to_f,
	                        "MonId"       => Afip::MONEDAS[moneda][:codigo],
	                        "MonCotiz"    => exchange_rate,
	                        "ImpOpEx"     => exento,
	                        "ImpTotal"	  => (Afip.own_iva_cond == :responsable_monotributo ? net : total).to_f.round(2),
	                        "CbteDesde"	  => next_bill_number,
	                        "CbteHasta"	  => next_bill_number
	                    }
	                }
	            }
	        }

	        detail = fecaereq["FeCAEReq"]["FeDetReq"]["FECAEDetRequest"]

	        if (Afip.own_iva_cond == :responsable_inscripto)
	        	detail["ImpIVA"] = iva_sum
	        	detail["Iva"] =  array_ivas
	        end

	        if !tributos.empty?
	        	detail["ImpTrib"]  = otros_imp
	        	detail["Tributos"] = array_tributos
	        end

		    unless concepto == "Productos" # En "Productos" ("01"), si se mandan estos parámetros la afip rechaza.
		        detail.merge!({"FchServDesde" => fch_serv_desde.strftime("%Y%m%d"),
		                      "FchServHasta"  => fch_serv_hasta.strftime("%Y%m%d"),
		                      "FchVtoPago"    => due_date.strftime("%Y%m%d")})
		    end

		    body.merge!(fecaereq)
		    pp body
		end

		def self.header(cant_reg, cbte_type, sale_point)
        	{"CantReg" => cant_reg.to_s, "CbteTipo" => cbte_type, "PtoVta" => sale_point}
      	end

      	def exchange_rate
	        return 1 if moneda == :peso
	        response = client.call :fe_param_get_cotizacion do
	          message = body.merge!({"MonId" => Afip::MONEDAS[moneda][:codigo]})
	        end
	        response.to_hash[:fe_param_get_cotizacion_response][:fe_param_get_cotizacion_result][:result_get][:mon_cotiz].to_f
	    end

    	def iva_sum
	      	iva_sum = 0.0
	      	self.ivas.each{ |i|
	        	iva_sum += i[2]
	      	}
	      	return iva_sum.round(2)
	    end

	    def next_bill_number
		    var = {"Auth" => Afip.auth_hash, "PtoVta" => sale_point, "CbteTipo" => cbte_type}
		    resp = client.call :fe_comp_ultimo_autorizado do
		        message(var)
		    end

		    resp.to_hash[:fe_comp_ultimo_autorizado_response][:fe_comp_ultimo_autorizado_result][:cbte_nro].to_i + 1
	    end

	    def setup_response(response)
		    # TODO: turn this into an all-purpose Response class
				pp response
		    result          = response[:fecae_solicitar_response][:fecae_solicitar_result]

		    if not result[:fe_det_resp] or not result[:fe_cab_resp] then
		    # Si no obtuvo respuesta ni cabecera ni detalle, evito hacer '[]' sobre algo indefinido.
		    # Ejemplo: Error con el token-sign de WSAA
		        keys, values = {
		            :errores => result[:errors],
		            :header_result => {:resultado => "X" },
		            :observaciones => nil
		        }.to_a.transpose
		        @response = (defined?(Struct::ResponseMal) ? Struct::ResponseMal : Struct.new("ResponseMal", *keys)).new(*values)
		        return
		    end

		    response_header = result[:fe_cab_resp]
		    response_detail = result[:fe_det_resp][:fecae_det_response]

		    request_header  = body["FeCAEReq"]["FeCabReq"].underscore_keys.symbolize_keys
		    request_detail  = body["FeCAEReq"]["FeDetReq"]["FECAEDetRequest"].underscore_keys.symbolize_keys

		    # Esto no funciona desde que se soportan múltiples alícuotas de iva simultáneas
		    # FIX ? TO-DO
		    # iva             = request_detail.delete(:iva)["AlicIva"].underscore_keys.symbolize_keys
		    # request_detail.merge!(iva)

		    if result[:errors] then
		        response_detail.merge!( result[:errors] )
		    end

		    response_hash = {
		    	:header_result => response_header.delete(:resultado),
                :authorized_on => response_header.delete(:fch_proceso),
                :detail_result => response_detail.delete(:resultado),
                :cae_due_date  => response_detail.delete(:cae_fch_vto),
                :cae           => response_detail.delete(:cae),
                :iva_id        => request_detail.delete(:id),
                :iva_importe   => request_detail.delete(:importe),
                :moneda        => request_detail.delete(:mon_id),
                :cotizacion    => request_detail.delete(:mon_cotiz),
                :iva_base_imp  => request_detail.delete(:base_imp),
                :doc_num       => request_detail.delete(:doc_nro),
                :observaciones => response_detail.delete(:observaciones),
                :errores       => response_detail.delete(:err)
		    }.merge!(request_header).merge!(request_detail)

		    keys, values  = response_hash.to_a.transpose
		    @response = (defined?(Struct::Response) ? Struct::Response : Struct.new("Response", *keys)).new(*values)
		end

		def authorized?
        	!response.nil? && response.header_result == "A" && response.detail_result == "A"
    	end
	end
end
