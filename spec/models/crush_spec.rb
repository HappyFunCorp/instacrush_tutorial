require 'rails_helper'

RSpec.describe Crush, type: :model do
  let( :main_user ) { create( :user )}

  let( :user_1 ) { create( :instagram_user, username: "user_1", user: main_user ) }
  let( :user_2 ) { create( :instagram_user, username: "user_2" ) }
  let( :user_3 ) { create( :instagram_user, username: "user_3" ) }
  let( :user_4 ) { create( :instagram_user, username: "user_4" ) }
  let( :user_5 ) { create( :instagram_user, username: "user_5" ) }
  let( :user_6 ) { create( :instagram_user, username: "user_6" ) }
  let( :user_7 ) { create( :instagram_user, username: "user_7" ) }
  let( :user_8 ) { create( :instagram_user, username: "user_8" ) }

  def make_media( likers, commenters )
    post = create( :instagram_medium, instagram_user: user_1 )
    [likers].flatten.each do |user|
      post.likes.create( instagram_user: user )
    end
    [commenters].flatten.each do |user|
      post.comments.create( instagram_user: user )
    end
    post
  end

  context "plumbing" do
    it "should create a post with likes and comments" do
      make_media [user_2, user_3], user_4

      expect( InstagramMedia.count ).to eq(1)
      expect( InstagramInteraction.count ).to eq(3)

      post = InstagramMedia.first

      expect( post.likes.count ).to eq(2)
      expect( post.comments.count ).to eq(1)
    end
  end

  it "should count likes towards a crush" do
    make_media [user_2, user_3], []
    make_media user_2, []

    c = Crush.find_for_user main_user

    expect( c.instagram_user ).to eq( main_user.instagram_user )
    expect( c.crush_user ).to eq( user_2 )
    expect( c.likes_count ).to eq( 2 )
    expect( c.comments_count ).to eq( 0 )
  end

  it "should count comments towards a crush" do
    make_media [user_4, user_5], [user_6]
    make_media [user_7, user_8], [user_6]

    c = Crush.find_for_user main_user

    expect( c.instagram_user ).to eq( main_user.instagram_user )
    expect( c.crush_user ).to eq( user_6 )
    expect( c.likes_count ).to eq( 0 )
    expect( c.comments_count ).to eq( 2 )
  end

  it "should used the combined total" do
    make_media [user_2, user_4, user_5], [user_6]
    make_media [user_7, user_8], [user_2]

    c = Crush.find_for_user main_user

    expect( c.instagram_user ).to eq( main_user.instagram_user )
    expect( c.crush_user ).to eq( user_2 )
    expect( c.likes_count ).to eq( 1 )
    expect( c.comments_count ).to eq( 1 )
  end
end
