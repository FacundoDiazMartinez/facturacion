Aws.config.update({
  region: 'sa-east-1',
  credentials: Aws::Credentials.new('AKIAIJ5KZXLA42Y376PA', 'wHsBLVsf9QG5PKEhoTC1j/W8BKszkXLCeSIQJT/H'),
})

S3_BUCKET = Aws::S3::Resource.new.bucket('litecode.facturacion')