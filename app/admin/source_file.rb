ActiveAdmin.register SourceFile do
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

  filter :path
  filter :created_at
  filter :updated_at

  index do
    column :id
    column :project
    column :path
    column :created_at
    #column :updated_at
    actions
  end

  show :title => :path do
    div do
      attributes_table do
        row :id
        row :project
        row :path
        row :created_at
        row :updated_at
      end
    end

    div do
      table_for(source_file.rubocop_offenses) do
        column(:cop_name)
        column(:message)
        column(:severity)
        column('Line', :location_line)
        column('Column', :location_column)
        column('Length', :location_length)
      end
    end

    div do
      raw CodeRay.scan(source_file.content, :ruby).div
    end

  end
end
