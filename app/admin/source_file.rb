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

  index do
    column :id
    column :project
    column :path
    column :created_at
    #column :updated_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :project
      row :path
      row :created_at
      row :updated_at
      row :content do |model|
        raw CodeRay.scan(model.content, :ruby).div
      end
      row :rubocop_offenses
    end
  end
end
