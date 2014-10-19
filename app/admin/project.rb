ActiveAdmin.register Project do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  permit_params :username, :name, :description, :rubocop_run_started_at, :rubocop_last_run_at
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end

  scope :all, :default => true do |projects|
      projects
  end

  scope :new do |projects|
      projects.where("projects.rubocop_last_run_at IS NULL AND projects.rubocop_run_started_at IS NULL")
  end

  scope :indexing do |projects|
      projects.where("(projects.rubocop_last_run_at IS NULL AND projects.rubocop_run_started_at IS NOT NULL) OR (projects.rubocop_last_run_at < projects.rubocop_run_started_at)")
  end

  member_action :send_the_cops_now, :method => :get do
      RubocopWorker.perform_async(params[:id], true)
      redirect_to({action: :show}, notice: "Copping it!")
  end

  collection_action :send_cops_everywhere, :method => :get do
    Project.all.each do |project|
      RubocopWorker.perform_async(project.id) unless project.rubocop_running?
    end
    redirect_to({action: :index}, notice: "Now is a good time to check the sidekiq scheduler page!" )
  end

  collection_action :force_cops_everywhere, :method => :get do
    Project.all.each do |project|
      RubocopWorker.perform_async(project.id, true) unless project.rubocop_running?
    end
    redirect_to({action: :index}, notice: "Now is a good time to check the sidekiq scheduler page!" )
  end

  action_item :only => :show do
    link_to('Send in the cops!', send_the_cops_now_admin_project_path(params[:id]))
  end

  index do
    column "Repo", :sortable => :name do |project|
      link_to project.full_name, admin_project_path(project)
    end

    column :description
    column 'Files', :source_files_count
    column 'Offenses', :rubocop_offenses_count
    column :rubocop_last_run_at
    column 'Run Time', :last_index_run_time,
            :sortable => "extract(epoch from (projects.rubocop_last_run_at - projects.rubocop_run_started_at))"
    column :created_at
    column :updated_at

    column "Actions" do |resource|
      links = ''.html_safe
      if controller.action_methods.include?('edit')
        links += link_to I18n.t('active_admin.edit'), edit_resource_path(resource), :class => "member_link edit_link"
      end

      links += link_to "Send in the cops!", send_the_cops_now_admin_project_path(resource)

      links
    end
  end

  filter :name
  filter :username
  filter :description
  filter :created_at
  filter :updated_at
  filter :rubocop_run_started_at
  filter :rubocop_last_run_at

  form do |f|
    f.inputs do
      f.input :username
      f.input :name
      f.input :description
      f.input :rubocop_run_started_at, :as => :datepicker
      f.input :rubocop_last_run_at, :as => :datepicker
    end
    f.actions
  end

  show :title => :full_name do
    div do
      attributes_table do
        row :id
        row :name
        row :username
        row :description
        row :created_at
        row :updated_at
        row :source_files_count
        row :rubocop_offenses_count
        row :pushed_at
        row :default_branch
        row :rubocop_run_started_at
        row :rubocop_last_run_at

        #row :repository_data
      end
    end

    div do
      table_for(project.source_files) do
        column("File", :path) { |sf| link_to( sf.path, admin_source_file_path(sf)) }
      end
    end


    div do
      raw CodeRay.scan(project.repository_data.to_json, :json).div
    end

  end

end
