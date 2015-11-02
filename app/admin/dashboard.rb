ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Users" do
          render partial: "admin/chart", locals: { scope: 'users' }
        end
      end
    end

    columns do
      column do
        panel "Instagram Users" do
          render partial: "admin/chart", locals: { scope: 'instagram_users' }
        end
      end
      column do
        panel "Crushes" do
          render partial: "admin/chart", locals: { scope: 'crushes' }
        end
      end
    end

    columns do
      column do
        panel "Likes" do
          render partial: "admin/chart", locals: { scope: 'likes' }
        end
      end
      column do
        panel "Comments" do
          render partial: "admin/chart", locals: { scope: 'comments' }
        end
      end
    end
  end
end