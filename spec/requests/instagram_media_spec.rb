require 'rails_helper'

RSpec.describe "InstagramMedia", type: :request do
  describe "GET /instagram_media" do
    it "works! (now write some real specs)" do
      get instagram_media_path
      expect(response).to have_http_status(302)
    end
  end
end
