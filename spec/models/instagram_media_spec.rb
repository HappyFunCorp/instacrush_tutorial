require 'rails_helper'

RSpec.describe InstagramMedia, type: :model do
  let( :user ) { create( :user ) }
  let!( :instagram_auth ) { create( :identity, provider: :instagram, user: user, accesstoken: INSTAGRAM_ACCESS_TOKEN ) }
 
  it "should load in media objects for the user" do
    expect( InstagramMedia.count ).to eq( 0 )

    VCR.use_cassette 'instagram/recent_feed_for_user' do
      InstagramMedia.recent_feed_for_user( user.instagram_client, user.find_instagram_user )
    end

    expect( InstagramMedia.count ).to_not eq(0)
  end

  it "should add data to the media object" do
    VCR.use_cassette 'instagram/recent_feed_for_user' do
      InstagramMedia.recent_feed_for_user( user.instagram_client, user.find_instagram_user )
    end

    media = InstagramMedia.all.first

    expect( media ).to_not be_nil
    expect( media.media_id ).to eq( "1109367881914714505_509161" )
    expect( media.media_type ).to eq( "image" )
    expect( media.comments_count ).to eq( 0 )
    expect( media.likes_count ).to eq( 7 )
  end

  it "each post should have an associated instagram user" do
    VCR.use_cassette 'instagram/recent_feed_for_user' do
      InstagramMedia.recent_feed_for_user( user.instagram_client, user.find_instagram_user )
    end

    InstagramMedia.all.each do |a|
      expect( a.instagram_user ).to_not be_nil
    end
  end

  context "relationships" do
    before( :each ) do
      VCR.use_cassette 'instagram/recent_feed_for_user_with_interactions' do
        InstagramMedia.recent_feed_for_user( user.instagram_client, user.find_instagram_user )
        user.find_instagram_user.posts.each do |post|
          post.load_interaction_data( user.instagram_client )
        end
      end
    end

    it "should associate an instragram user with the user" do
      expect( user.instagram_user ).to_not be_nil
    end

    it "should associate posts with the instragram user" do
      expect( user.instagram_user.posts.count ).to be > 0
    end

    it "should associate comments with a post" do
      post = InstagramMedia.first
      expect( post ).to_not be_nil
      expect( post.comments.count ).to eq( 0 )
    end

    it "should associate likes with a post" do
      post = InstagramMedia.first
      expect( post ).to_not be_nil
      expect( post.likes.count ).to eq( 7 )
    end

    it "should know the users surrounding the user" do
      count = user.instagram_user.nearby_users.count
      create( :instagram_user )
      expect( user.instagram_user.nearby_users.count ).to eq( count )
    end
  end

  context "comments" do
    before( :each ) do
      VCR.use_cassette 'instagram/recent_feed_for_user_with_interactions' do
        InstagramMedia.recent_feed_for_user( user.instagram_client, user.find_instagram_user, true )
        user.find_instagram_user.posts.each do |post|
          post.load_interaction_data( user.instagram_client )
        end
      end
    end

    it "should load multiple InstagramUsers" do
      expect( InstagramUser.count ).to be > 1
    end

    it "should have created many instagram interactions" do
      expect( InstagramInteraction.where( is_like: false ).count ).to be > 0
    end
  end

  context "interactions" do
    before( :each ) do
      VCR.use_cassette 'instagram/recent_feed_for_user_with_interactions' do
        InstagramMedia.recent_feed_for_user( user.instagram_client, user.find_instagram_user, true )
        user.find_instagram_user.posts.each do |post|
          post.load_interaction_data( user.instagram_client )
        end
      end
    end

    it "should check that the comment count are the same as in the media object" do
      user.instagram_user.posts.each do |post,idx|
        expect( post.comments.count ).to eq( post.comments_count)
      end
    end

    it "should check that the likes count are the same as in the media object" do
      user.instagram_user.posts.each do |post,idx|
        expect( post.likes.count ).to be_within( 2 ).of( post.likes_count)
      end
    end
  end
end
