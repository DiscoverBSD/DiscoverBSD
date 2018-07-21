class Post < ApplicationRecord
  belongs_to :author, class_name: 'User'
  belongs_to :approved_by, class_name: 'User', optional: true
  belongs_to :declined_by, class_name: 'User', optional: true

  validates :title, presence: true
  validates :url, presence: true
  validates :description, presence: true

  scope :aprroved, -> { where(approved: true) }
end
