Afip.setup do |config|
	config.pkey = "#{Rails.root}/app/certs/sanantonio.key"
	config.cert = "#{Rails.root}/app/certs/sanantonio.cert"
	config.environment = :test
	config.cuit = "30709038148"
	config.openssl_bin = "/usr/local/Cellar/openssl/1.0.2o_2/bin/openssl"
	config.service_url = "https://fwshomo.afip.gov.ar/wsctg/services/CTGService_v3.0?wsdl"
end