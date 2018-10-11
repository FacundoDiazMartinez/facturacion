class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

# Storage configuration within the uploader supercedes the global CarrierWave
# config, so either comment out `storage :file`, or remove that line, otherwise

# AWS will not be used.
storage :aws

# You can find a full list of custom headers in AWS SDK documentation on
# AWS::S3::S3Object
  def download_url(filename)
    url(response_content_disposition: %Q{attachment; filename="#{filename}"})
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def cache_dir
    "/tmp/avatarTmp"
  end

  #process :resize_to_fit => [200, 200]

  version :thumb do
    process :resize_to_fit => [70, 70]
  end

  #version :large do
  #  process :resize_to_fit => [200, 200]
  #end

  def extension_white_list
    %w(jpg jpeg png)
  end



  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
  	if is_company?
  		"/images/default_company.png"
  	else
  		"/images/default_user.png"
  	end
    
  end

  private

  def is_company?
    pp model.class.name == "Company"
  end
end