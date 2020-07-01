Afip.setup do |config|
	config.pkey 		= "#{Rails.root}/app/afip/facturacion.key"
	config.cert 		= "#{Rails.root}/app/afip/testing.crt"
	config.environment 	= :test
	config.cuit 		= "20368642682" #"30709038148"
	config.openssl_bin 	= "/usr/local/opt/openssl/bin/openssl"
	if Rails.env.production?
		config.openssl_bin = "/usr/bin/openssl"  #production y reiniciar server
	end
	#config.service_url = "https://fwshomo.afip.gov.ar/wsctg/services/CTGService_v4.0?wsdl"
	config.service_url  = "https://wswhomo.afip.gov.ar/wsfev1/service.asmx?WSDL"
end
