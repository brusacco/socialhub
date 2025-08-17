# frozen_string_literal: true

class Profile < ApplicationRecord
  has_many :social_accounts, dependent: :destroy
  accepts_nested_attributes_for :social_accounts, allow_destroy: true

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true
  enum :profile_type, { hombre: 0, mujer: 1, medio: 2, marca: 3, estatal: 4, meme: 5, programa: 6 }

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id name slug updated_at profile_type]
  end
end
