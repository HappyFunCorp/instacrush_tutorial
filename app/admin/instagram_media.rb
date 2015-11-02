ActiveAdmin.register InstagramMedia do 
  menu priority: 5

  filter :instagram_user_username, as: :string
  filter :likes_count
  filter :comments_count
  filter :created_at

  index do
    selectable_column

    column :id
    column :username do |r|
      link_to r.instagram_user.username, admin_instagram_user_path( r.instagram_user )
    end
    column :thumbnail do |r|
      link_to r.link do
        image_tag r.thumbnail_url
      end
    end
    column :likes_count
    column :comments_count
    column :created_at
    actions
  end
end