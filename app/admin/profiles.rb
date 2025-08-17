# frozen_string_literal: true

ActiveAdmin.register Profile do
  permit_params :name,
                :slug,
                :profile_type,
                social_accounts_attributes: %i[id network username uid display_name data followers following _destroy]

  filter :name
  filter :created_at
  filter :updated_at

  actions :all, except: []

  # index, show, form ...
  form do |f|
    f.inputs do
      f.input :name
      f.input :slug
      f.input :profile_type
      f.has_many :social_accounts, allow_destroy: true do |sa|
        sa.input :network
        sa.input :username
        sa.input :uid
        sa.input :display_name
        sa.input :followers
        sa.input :following
      end
    end
    f.actions
  end
end
