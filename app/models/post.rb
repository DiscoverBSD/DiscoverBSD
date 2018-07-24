class Post < ApplicationRecord
  belongs_to :author, class_name: 'User'
  belongs_to :approved_by, class_name: 'User', optional: true
  belongs_to :declined_by, class_name: 'User', optional: true

  validates :title, presence: true
  validates :url, presence: true
  validates :description, presence: true
  validates :slug, presence: true, uniqueness: true

  scope :approved, -> { where(approved: true, declined: false) }
  scope :not_yet_approved, -> { where(approved: false, declined: false) }
  scope :declined, -> { where(declined: true) }

  before_validation(on: :create) do
    self.slug = SecureRandom.hex(5) unless self.slug.present?
  end
end
