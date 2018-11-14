PDFKit.configure do |config|
  config.wkhtmltopdf = `which wkhtmltopdf`.gsub(/\n/, '')
end