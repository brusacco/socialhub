# frozen_string_literal: true

class SocialAccount < ApplicationRecord
  belongs_to :profile
  enum :network, { Instagram: 0, Facebook: 1, TikTok: 2, Twitter: 3 }
  def self.ransackable_associations(_auth_object = nil)
    ['profile']
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      created_at
      data
      display_name
      followers
      following
      id
      network
      profile_id
      uid
      updated_at
      username
    ]
  end

  def update_profile_info
    if network == 'Instagram' && username.present?
      api_data = InstagramServices::GetProfileData.call(username)
    elsif network == 'Facebook' && uid.present?
      api_data = FacebookServices::GetProfileData.call(uid)
    elsif network == 'TikTok' && username.present?
      api_data = TikTokServices::GetProfileData.call(username)
    elsif network == 'Twitter' && uid.present?
      api_data = TwitterServices::GetProfileData.call(uid)
    end
    return unless api_data.success?

    update_attribute!(:data, api_data.data)
  end
end
