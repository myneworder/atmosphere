# == Schema Information
#
# Table name: appliance_sets
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  priority           :integer          default(50), not null
#  appliance_set_type :string(255)      default("workflow"), not null
#  user_id            :integer          not null
#  created_at         :datetime
#  updated_at         :datetime
#

class ApplianceSet < ActiveRecord::Base
  extend Enumerize

  belongs_to :user

  validates_presence_of :priority, :appliance_set_type, :user

  validates :priority, numericality: { only_integer: true }, inclusion: 1..100

  enumerize :appliance_set_type, in: [:portal, :development, :workflow]
  validates :appliance_set_type, inclusion: %w(portal development workflow)
  validates :appliance_set_type, uniqueness: { scope: :user }, if: 'appliance_set_type == "development" or appliance_set_type == "portal"'

  attr_readonly :appliance_set_type

  has_many :appliances, dependent: :destroy

end
