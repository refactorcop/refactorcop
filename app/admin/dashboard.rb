ActiveAdmin.register_page "Dashboard" do
  # menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
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
              li link_to(project.full_name, admin_project_path(project)) + " (#{project.rubocop_offenses_count})"
            end
          end
        end
      end

      column do
        panel "" do
          text_node %{<iframe src="https://rpm.newrelic.com/public/charts/fm3gwRLo8rp" width="400" height="200" scrolling="no" frameborder="no"></iframe>}.html_safe
        end
      end
    end

    columns do
      column do
        div do
          br
          text_node %{<iframe src="https://rpm.newrelic.com/public/charts/exvinz78lL1" width="550" height="300" scrolling="no" frameborder="no"></iframe>}.html_safe
        end
      end

      column do
        div do
          br
          text_node %{<iframe src="https://rpm.newrelic.com/public/charts/6AxHUxITYCA" width="500" height="300" scrolling="no" frameborder="no"></iframe>}.html_safe
        end
      end
    end
  end # content
end
