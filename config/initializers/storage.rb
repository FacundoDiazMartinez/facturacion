CarrierWave.configure do |config|
  config.fog_provider = 'fog/aws'
  config.fog_credentials = {
      provider:              'AWS',
      aws_access_key_id:     'AKIAIJ5KZXLA42Y376PA',
      aws_secret_access_key: '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',
      region: 'sa-east-1'
  }
  config.fog_directory  = "litecode.acturacion"
  config.fog_public     = true
end