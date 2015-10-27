require 'rails_helper'

RSpec.describe "InstagramUsers", type: :request do
  describe "GET /instagram_users" do
    it "works! (now write some real specs)" do
      get instagram_users_path
      expect(response).to have_http_status(200)
    end
  end
end
