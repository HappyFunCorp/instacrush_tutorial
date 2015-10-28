require 'rails_helper'

RSpec.describe "InstagramInteractions", type: :request do
  describe "GET /instagram_interactions" do
    it "works! (now write some real specs)" do
      get instagram_interactions_path
      expect(response).to have_http_status(200)
    end
  end
end
