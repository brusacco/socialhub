# frozen_string_literal: true

ActiveAdmin.register SocialAccount do
  permit_params :profile_id, :network, :username, :uid, :display_name, :data, :followers, :following

  filter :profile
  filter :network
  filter :created_at
  filter :updated_at

  actions :all, except: []

  # index, show, form ...
end
