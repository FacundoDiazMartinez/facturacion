class AuthorizedPersonal < ApplicationRecord
  belongs_to :client

  def client
    Client.unscoped{ super }
  end
end
