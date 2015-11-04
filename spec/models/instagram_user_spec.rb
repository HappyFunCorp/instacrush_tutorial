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
    expect( iu.remote_id ).to eq( "509161" )
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
    InstagramUser.from_hash "username" => 'wschenk', "full_name" => 'Will Schenk', "id" => "509161"

    InstagramUser.from_hash "username" => 'wschenk', "full_name" => 'Will Schenk', 'counts' => { 'media' => 100 }

    expect( InstagramUser.count ).to eq(1)
    expect( InstagramUser.first.username ).to eq( 'wschenk' )
    expect( InstagramUser.first.remote_id ).to eq( "509161" )
    expect( InstagramUser.first.media_count ).to eq( 100 )
  end

  context "needing syncing" do
    it "a new object should be stale" do
      iu = create( :instagram_user )
      expect( iu.stale? ).to be_truthy
    end

    it "an object synced more than 12 hours ago should be stale" do
      iu = create( :instagram_user, last_synced: 13.hours.ago )
      expect( iu.stale? ).to be_truthy
    end

    it "an object synced 1 hours ago should not be stale" do
      iu = create( :instagram_user, last_synced: 1.hour.ago )
      expect( iu.stale? ).to be_falsey
    end
  end

  context "syncing" do
    before( :each ) do
      expect( instagram_auth ).to_not be_nil
    end

    it "should trigger a sync for a stale user" do
      assert_enqueued_with( job: UpdateUserFeedJob ) do
        InstagramUser.sync_feed_from_user user
      end
    end
  end
end
