# == Schema Information
#
# Table name: virtual_machine_templates
#
#  id                 :integer          not null, primary key
#  id_at_site         :string(255)      not null
#  name               :string(255)      not null
#  state              :string(255)      not null
#  compute_site_id    :integer          not null
#  virtual_machine_id :integer
#  appliance_type_id  :integer
#  created_at         :datetime
#  updated_at         :datetime
#

class VirtualMachineTemplate < ActiveRecord::Base
  belongs_to :source_vm, class_name: 'VirtualMachine', foreign_key: 'virtual_machine_id'
  has_many :instances, class_name: 'VirtualMachine'
  belongs_to :compute_site
  belongs_to :appliance_type
  validates_presence_of :id_at_site, :name, :state, :compute_site_id
  validates_uniqueness_of :id_at_site, :scope => :compute_site_id

  def uuid
    "#{compute_site_id}-tmpl-#{id_at_site}"
  end

end
