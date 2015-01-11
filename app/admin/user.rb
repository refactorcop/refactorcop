ActiveAdmin.register User do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  permit_params :email
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end

  scope :all, :default => true do |users|
    users
  end

  index do
    column "User", :sortable => :name do |user|
      link_to user.email, admin_user_path(user)
    end

    column 'Projects', :projects_count
    column :created_at
    column :updated_at

    column "Actions" do |resource|
      links = ''.html_safe
      if controller.action_methods.include?('edit')
        links += link_to I18n.t('active_admin.edit'), edit_resource_path(resource), :class => "member_link edit_link"
      end
      links
    end
  end

  filter :email
  filter :created_at
  filter :updated_at

  form do |f|
    f.inputs do
      f.input :email
    end
    f.actions
  end

  show :title => :email do
    div do
      attributes_table do
        row :id
        row :email
        row :github_uid
        #row :repository_data
      end
    end

    div do
      table_for(user.projects) do
        column("Projects", :full_name) { |p| link_to( p.full_name, admin_project_path(p)) }
      end
    end
  end
end
