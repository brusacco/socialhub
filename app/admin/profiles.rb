ActiveAdmin.register Profile do
  permit_params :name, :slug

  filter :name
  filter :created_at
  filter :updated_at

  actions :all, except: []

  # index, show, form ...
end
