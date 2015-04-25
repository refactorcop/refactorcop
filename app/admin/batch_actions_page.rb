ActiveAdmin.register_page "BatchActions" do
  menu :label => "Batch Actions"

  content do
    h1 t :dangerous_batch_actions
    div do
      link_to "Queue ALL projects if code changed", send_cops_everywhere_admin_projects_path
    end

    div do
      link_to "Force run ALL projects", force_cops_everywhere_admin_projects_path
    end
  end
end
