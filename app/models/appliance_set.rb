# == Schema Information
#
# Table name: appliance_sets
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  priority           :integer          default(50), not null
#  appliance_set_type :string(255)      default("development"), not null
#  user_id            :integer          not null
#  created_at         :datetime
#  updated_at         :datetime
#

class ApplianceSet < ActiveRecord::Base
  extend Enumerize

  validates_presence_of :priority, :appliance_set_type, :user_id

  validates :priority, numericality: { only_integer: true }, inclusion: 1..100

  enumerize :appliance_set_type, in: [:portal, :development, :workflow]
  validates :appliance_set_type, inclusion: %w(portal development workflow)
  validates :appliance_set_type, uniqueness: { scope: :user }, if: 'appliance_set_type == "development" or appliance_set_type == "portal"'

  attr_readonly :appliance_set_type


  belongs_to :user
  # This should also make sure the referenced entity exists; but we still should make a foreign key constraint in DB
  validates :user, presence: true

  has_many :appliances, dependent: :destroy
end