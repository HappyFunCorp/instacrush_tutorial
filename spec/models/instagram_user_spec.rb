require 'rails_helper'

RSpec.describe InstagramUser, type: :model do
  let( :user ) { create( :user ) }
  let( :instagram_auth ) { create( :identity, provider: :instagram, user: user, accesstoken: INSTAGRAM_ACCESS_TOKEN ) }

  it "should sync the users info" do
    expect( instagram_auth ).to_not be_nil
    expect( InstagramUser.count ).to eq( 0 )

    VCR.use_cassette( "instagram/user_sync" ) do
      InstagramUser.sync_from_user( user )
    end

    iu = InstagramUser.where( user_id: user.id ).first

    expect( iu ).to_not be_nil
    expect( iu.username ).to eq( "wschenk" )
    expect( iu.full_name ).to eq( "Will Schenk" )
    expect( iu.profile_picture ).to eq( "http://scontent.cdninstagram.com/hphotos-xaf1/t51.2885-19/11374591_955491831180543_1527410442_a.jpg" )
    expect( iu.media_count ).to eq( 680 )
    expect( iu.followed_count ).to eq( 191 )
    expect( iu.following_count ).to eq( 224 )
  end

  it "should create a user from a hash" do
    InstagramUser.from_hash 'username' => 'wschenk', 'full_name' => 'Will Schenk'

    expect( InstagramUser.count ).to eq(1)
    expect( InstagramUser.first.username ).to eq( 'wschenk' )
  end

  it "should update the read counts if it find them" do
    InstagramUser.from_hash "username" => 'wschenk', "full_name" => 'Will Schenk'

    InstagramUser.from_hash "username" => 'wschenk', "full_name" => 'Will Schenk', 'counts' => { 'media' => 100 }

    expect( InstagramUser.count ).to eq(1)
    expect( InstagramUser.first.username ).to eq( 'wschenk' )
    expect( InstagramUser.first.media_count ).to eq( 100 )
  end
end
