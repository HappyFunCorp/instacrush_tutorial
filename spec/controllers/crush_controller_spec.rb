require 'rails_helper'

RSpec.describe CrushController, :type => :controller do
  let!( :instagram_auth ) { create( :identity, provider: :instagram, user: user, accesstoken: INSTAGRAM_ACCESS_TOKEN ) }
  let!( :crush ) { create( :crush, instagram_user: instagram_user, crush_user: crush_user ) }

  let( :user ) { create( :user ) }
  let( :instagram_user ) { create( :instagram_user, user: user ) }
  let( :crush_user ) { create( :instagram_user, user: user ) }

  context "anonymous user" do
    before( :each ) do
      allow_message_expectations_on_nil
      login_with nil
    end

    it "index should redirect to login with instagram" do
      get :index
      expect( response ).to redirect_to( user_omniauth_authorize_path( :instagram ) )
    end

    it "loading should redirect to login with instagram" do
      get :loading
      expect( response ).to redirect_to( user_omniauth_authorize_path( :instagram ) )
    end

    it "should display a public crush" do
      get :show, slug: crush.slug
      expect( response ).to have_http_status(200)
    end
  end

  context "new user" do
    let!( :clean_instagram_auth ) { create( :identity, provider: :instagram, user: clean_user, accesstoken: INSTAGRAM_ACCESS_TOKEN ) }
    let( :clean_user ) { create( :user ) }

    before( :each ) do
      expect( clean_user.instagram_user ).to be_nil
      allow_message_expectations_on_nil
      login_with clean_user
    end

    it "should queue up the syncing job when you get the index page" do
      assert_enqueued_with( job: UpdateUserFeedJob ) do
        VCR.use_cassette 'instagram/user_sync' do
          get :index
        end
      end
      expect( response ).to redirect_to( loading_crush_index_path )
      assert_no_enqueued_jobs do
        get :loading
      end
      expect( response ).to have_http_status( 200 )
    end

    it "should queue up the syncing job if you hit the loading page first" do
      assert_enqueued_with( job: UpdateUserFeedJob ) do
        VCR.use_cassette 'instagram/user_sync' do
          get :loading
        end
      end
      expect( response ).to have_http_status( 200 )
    end
  end

  let!( :instagram_interaction ) { create( :instagram_interaction, instagram_user: crush_user, instagram_media: post ) }
  let( :post ) { create( :instagram_medium, instagram_user: instagram_user )}

  context "up-to-date user" do
    before( :each ) do
      instagram_user.update_attribute( :interaction_info_finished_at, 1.hour.ago )
      instagram_user.update_attribute( :interaction_info_state, 'synced' )
      user.reload
      allow_message_expectations_on_nil
      login_with user
    end

    it "index should redirect to their crush" do
      get :index
      crush.reload # slug should get updated
      expect( response ).to redirect_to( crush_path( crush.slug ) )
    end

    it "loading should redirect to their crush" do
      get :loading
      crush.reload # slug should get updated
      expect( response ).to redirect_to( crush_path( crush ) )
    end

    it "should display their crush" do
      get :show, slug: crush.slug
      expect( response ).to have_http_status( 200 )
    end
  end

  context "stale user" do
    before( :each ) do
      allow_message_expectations_on_nil
      login_with user
    end

    it "index should redirect to their crush" do
      assert_enqueued_with( job: UpdateUserFeedJob ) do
        get :index
      end
      expect( response ).to redirect_to( loading_crush_index_path )
    end

    it "loading should remain on loading if it's not loaded yet" do
      get :loading
      expect( response ).to have_http_status( 200 )
    end

    it "loading should redirect to their crush if it's been loaded" do
      get :loading
      expect( response ).to have_http_status( 200 )

      instagram_user.update_attribute( :interaction_info_finished_at, 1.hour.ago )
      instagram_user.update_attribute( :interaction_info_state, "synced" )
      user.reload
      get :loading
      crush.reload
      expect( response ).to redirect_to( crush_path( crush ) )
    end

    it "should display their crush" do
      get :show, slug: crush.slug
      expect( response ).to have_http_status( 200 )
    end
  end

end


