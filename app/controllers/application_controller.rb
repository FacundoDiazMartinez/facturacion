class ApplicationController < ActionController::Base
 before_action :authenticate_user!

	def get_localities
		render json: ::Afip::CTG.new().consultar_localidades(params[:city_id])
	end

	def set_s3_direct_post
      	@s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
    end
end
