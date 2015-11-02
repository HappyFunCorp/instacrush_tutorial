ActiveAdmin.register Crush do
  menu priority: 2

  filter :instagram_user_username, as: :string
  filter :crush_user_username, as: :string
  filter :slug
  filter :likes_count
  filter :comments_count

  index do
    selectable_column
    column :id
    column :main_username do |c|
      link_to c.instagram_user.username, admin_instagram_user_path( c.instagram_user )
    end
    column :crush_username do |c|
      link_to c.crush_user.username, admin_instagram_user_path( c.crush_user )
    end
    column :likes_count
    column :comments_count
    column :slug do |c|
      link_to c.slug, c
    end
    column :created_at
    actions
  end

  controller do
    def find_resource
      Crush.where(slug: params[:id]).first!
    end
  end
end