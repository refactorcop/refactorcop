ActiveAdmin.register RubocopOffense do


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


  index do
    column :id
    column :source_file, sortable: "source_files.path"
    column :severity
    column :cop_name
    column :message
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :severity
      row :cop_name
      row :message
      row :created_at
      row :updated_at
      row :location_line
      row :location_column
      row :location_length
      row :github_link do |model|
        link_to model.github_link, model.github_link
      end
      row "Source Code" do |model|
        lines = model.source_file.content.lines[model.line_range]
        raw CodeRay.scan(lines.join("\n"), :ruby).div({
          line_numbers: :inline,
          line_number_start: model.location_line - 1
        })
      end
    end
  end

  controller do
    def scoped_collection
      end_of_association_chain.includes(:source_file)
    end
  end
end
