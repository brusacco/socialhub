# frozen_string_literal: true

class Profile < ApplicationRecord
  validates :name, :slug, presence: true
  validates :slug, uniqueness: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id name slug updated_at profile_type]
  end
end
