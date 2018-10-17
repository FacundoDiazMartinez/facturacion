class ApplicationController < ActionController::Base
 before_action :authenticate_user!

	def get_localities
		render json: Locality.where(province_id: params[:city_id]).map{|l| [l.id, l.name]}
	end

	def set_s3_direct_post
      	@s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
    end
end
