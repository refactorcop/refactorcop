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

  controller do
    def scoped_collection
      end_of_association_chain.includes(:source_file)
    end
  end
end
