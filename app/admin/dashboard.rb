ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do

    # Here is an example of a simple dashboard with columns and panels.
    #
    columns do
      column do
        panel "Recent Projects" do
          ul do
            Project.order("created_at DESC").take(5).map do |project|
              li link_to(project.full_name, admin_project_path(project))
            end
          end
        end
      end

      column do
        panel "Worst Projects" do
          ul do
            Project.order("rubocop_offenses_count DESC").take(5).map do |project|
              li link_to(project.full_name, admin_project_path(project))
            end
          end
        end
      end
    end
  end # content
end
