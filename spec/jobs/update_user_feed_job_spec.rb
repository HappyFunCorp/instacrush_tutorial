require 'rails_helper'

RSpec.describe UpdateUserFeedJob, type: :job do
  let( :user ) { create( :user ) }
  let!( :instagram_auth ) { create( :identity, provider: :instagram, user: user, accesstoken: INSTAGRAM_ACCESS_TOKEN ) }
  let!( :instagram_user ) { create( :instagram_user, username: 'wschenk', user: user ) }
 
  it "should create a job when requesting a synched user" do
    assert_enqueued_with( job: UpdateUserFeedJob ) do
      expect( instagram_user.sync_if_needed ).to be_truthy
    end

    expect( instagram_user.state ).to eq( 'queued' )
  end

  it "should not double enqueue a job" do
    assert_enqueued_with( job: UpdateUserFeedJob ) do
      expect( instagram_user.sync_if_needed ).to be_truthy
    end

    expect( instagram_user.state ).to eq( 'queued' )

    assert_no_enqueued_jobs do
      expect( instagram_user.sync_if_needed ).to be_falsey
    end
  end

  it "should actually sync the users feed" do
    expect( InstagramMedia.count ).to eq( 0 )

    VCR.use_cassette 'instagram/recent_feed_for_user' do
      UpdateUserFeedJob.perform_now( user.id )
    end

    instagram_user.reload

    expect( instagram_user.stale? ).to be_falsey
    expect( instagram_user.state ).to eq( "synced" )
    expect( InstagramMedia.count ).to_not eq(0)
  end
end
