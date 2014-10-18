ActiveAdmin.register Project do


  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end


  member_action :send_the_cops_now, :method => :get do
      RubocopWorker.perform_async(params[:id])
      redirect_to action: :show, notice: "Copping it!"
  end

  index do
    column :id
    column "Repo" do |project|
      link_to project.full_name, admin_project_path(project)
    end
    column :description
    column 'Files', :source_files_count
    column :created_at
    column :updated_at

    column "Actions" do |resource|
      links = ''.html_safe
      if controller.action_methods.include?('show')
        links += link_to I18n.t('active_admin.view'), resource_path(resource), :class => "member_link view_link"
      end
      if controller.action_methods.include?('edit')
        links += link_to I18n.t('active_admin.edit'), edit_resource_path(resource), :class => "member_link edit_link"
      end

      links += link_to "Send in the cops!", send_the_cops_now_admin_project_path(resource)

      links
    end
  end

  form do |f|
    f.inputs do
      f.input :username
      f.input :name
      f.input :description
    end
    f.actions
  end
end
