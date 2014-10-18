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
      RubocopWorker.perform_async(params[:id], true)
      redirect_to action: :show, notice: "Copping it!"
  end

  action_item :only => :show do
    link_to('Send in the cops!', send_the_cops_now_admin_project_path(params[:id]))
  end

  index do
    column :id

    column "Repo", :sortable => :name do |project|
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


  show :title => :title do
    div do
      attributes_table_for project, :campaign, :user, :poster, :url_homepage, :url_facebook, :url_offer, :rating_average
      multi_field :title
    end

    div :class => "tabs" do
      ul do
        li link_to "Files", "#tabs-files"
        li link_to "Offenses", "#tabs-offenses"
        li link_to "Admin Comments", "#tabs-admin-comments"
      end
      div :id => "tabs-files" do
        table_for(project.source_files) do
          column("Video", :asset) {|video| video_tag(video.asset, :controls => true, :size => "460x292") }
         end
      end

      div :id => "tabs-questions", :class => "tabs" do
        locale_tabs

        I18n.available_locales.each do |locale|
          div :id => "tabs-#{locale}" do
            clip.questions.each_with_index do |q,i|
              ql = q.translations.find_by_locale locale.to_s
              span ql.title
              ul do
                q.answers.each do |a|
                  al = a.translations.find_by_locale locale.to_s
                  li al.title, :class => q.answer_id == a.id ? "correct" : "false"
                end
              end
            end
          end
        end
      end

      div :id => "tabs-images" do
        image_tag(clip.thumbnail)
      end
      div :id => "tabs-user-comments" do
        table do
          resource.comments.order("created_at DESC").each do |comment|
            tr(:class => cycle("odd", "even")) do
              td { comment.created_at.strftime("%d/%m/%y") }
              td { auto_link comment.owner }
              td { simple_format comment.body }
            end
            comment.comments.each do |reply|
              tr(:class => current_cycle) do
                td { reply.created_at.strftime("%d/%m/%y") }
                td { auto_link reply.owner }
                td { simple_format "|->#{reply.body}" }
              end
            end
          end
        end
      end

      div :id => "tabs-admin-comments" do
        active_admin_comments
      end
    end

    div :id => "stats",:class => "tabs" do
      ul do
        li link_to "Stats", "#tabs-stats"
        li link_to "Demographics", "#tabs-demographics"
      end
      panel nil, :id => "tabs-stats" do
        render('/admin/stats/views_answers', :renderer => "clip", :user => current_user)
      end
      panel nil, :id => "tabs-demographics" do
          render('/admin/stats/demographics', :renderer => "clip", :user => current_user)
      end
    end
  end




end
