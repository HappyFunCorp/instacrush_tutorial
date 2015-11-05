ActiveAdmin.register InstagramUser  do
  menu priority: 4

  filter :username
  filter :full_name
  filter :created_at
  filter :media_count
  filter :followed_count
  filter :following_count
  filter :recent_posts_count
  filter :recent_likes_count
  filter :recent_comments_count
  filter :member_since
  filter :last_synced

  index do
    selectable_column
    column :id
    column :username do |r|
      link_to r.username, admin_instagram_user_path( r )
    end
    column :full_name
    column "Profile" do |u|
      image_tag u.profile_picture
    end
    column :media_count
    column :followed_count
    column :following_count
    column :recent_posts_count
    column :recent_likes_count
    column :recent_comments_count

    column :member_since
    column :created_at
    actions do |user|
      link_to "Sync", load_info_admin_instagram_user_path( user ), method: :put 
    end
  end

  show do
    panel "Interactions" do
      table_for instagram_user.interactions do
        column :who do |r|
          link_to r.instagram_user.username, admin_instagram_user_path( r.instagram_user )
        end
        column :photo do |r|
          image_tag r.instagram_media.thumbnail_url
        end
        column :is_like
        column :comment
      end
    end
    active_admin_comments
  end

  sidebar "Details", only: :show do
    attributes_table do
      row :user
      row :username do
        link_to resource.username, "http://instagram.com/#{resource.username}"
      end
      row :full_name
      row :profile_picture do
        image_tag resource.profile_picture
      end
      row :media_count
      row :followed_count
      row :following_count
      row :updated_at
      row :created_at
    end
  end

  member_action :load_info, method: :put do
    if resource.user
      InstagramUser.sync_from_user resource.user
      redirect_to resource_path, notice: "Refreshed user"
    else
      redirect_to resource_path, notice: "No accesstoken associated with this user"
    end
  end

  action_item "Load User Info", only: :show do
    link_to "Load User Info", load_info_admin_instagram_user_path( resource ), method: :put 
  end

  controller do
    def find_resource
      InstagramUser.where(username: params[:id]).first!
    end
  end
end