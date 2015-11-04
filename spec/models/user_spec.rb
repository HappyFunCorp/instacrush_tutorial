require 'rails_helper'

RSpec.describe User, type: :model do
  let( :user ) { create( :user ) }
  let!( :instagram_auth ) { create( :identity, provider: :instagram, user: user, accesstoken: INSTAGRAM_ACCESS_TOKEN ) }

  context "instagram_user" do
    it "should load the instagram_user for the user" do
      VCR.use_cassette 'instagram/user_sync' do
        expect( user.find_instagram_user.username ).to eq( 'wschenk' )
      end
    end

    it "should cache the results" do
      VCR.use_cassette 'instagram/user_sync' do
        expect( user.find_instagram_user.username ).to eq( 'wschenk' )
      end

      expect( user.find_instagram_user.username ).to eq( 'wschenk' )
    end
  end
end
