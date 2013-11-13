# == Schema Information
#
# Table name: appliance_types
#
#  id                :integer          not null, primary key
#  name              :string(255)      not null
#  description       :text
#  shared            :boolean          default(FALSE), not null
#  scalable          :boolean          default(FALSE), not null
#  visible_for       :string(255)      default("owner"), not null
#  preference_cpu    :float
#  preference_memory :integer
#  preference_disk   :integer
#  security_proxy_id :integer
#  user_id           :integer
#  created_at        :datetime
#  updated_at        :datetime
#

require 'spec_helper'

describe ApplianceType do

  subject { FactoryGirl.create(:appliance_type) }

  expect_it { to be_valid }

  expect_it { to validate_presence_of :name }
  expect_it { to validate_presence_of :visible_for }

  expect_it { to validate_uniqueness_of :name }

  expect_it { to ensure_inclusion_of(:visible_for).in_array(%w(owner developer all)) }

  expect_it { to have_db_index(:name).unique(true) }

  [:preference_memory, :preference_disk, :preference_cpu].each do |attribute|
    expect_it { to validate_numericality_of attribute }
    expect_it { should_not allow_value(-1).for(attribute) }
  end


  it 'should set proper default values' do
    expect(subject.visible_for).to eql 'owner'
    expect(subject.shared).to eql false
    expect(subject.scalable).to eql false
  end

  expect_it { to belong_to :security_proxy }
  expect_it { to belong_to :author }
  expect_it { to have_many :appliances }
  expect_it { to have_many(:port_mapping_templates).dependent(:destroy) }
  expect_it { to have_many(:appliance_configuration_templates).dependent(:destroy) }
  expect_it { to have_many(:virtual_machine_templates).dependent(:destroy) }

  context 'has virtual_machine_templates or appliances (aka "is used")' do
    let(:appliance_type) { create(:appliance_type) }
    let(:user)  { create(:user) }
    let(:appliance_set) { create(:appliance_set, user: user) }
    let!(:appliance) { create(:appliance, appliance_set: appliance_set, appliance_type: appliance_type) }

    it 'is valid' do
      expect(appliance_type).to be_valid
      expect(appliance_type.appliances).not_to be_empty
    end

    it 'has a proper dependencies detection' do
      expect(appliance_type.has_dependencies?).to be_true
    end

    it 'is not destroyable without force' do
      appliance_type.destroy
      expect(appliance_type.errors).not_to be_empty
    end

  end

end
