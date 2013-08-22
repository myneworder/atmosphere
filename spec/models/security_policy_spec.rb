# == Schema Information
#
# Table name: security_policies
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  payload    :text
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe SecurityPolicy do
  expect_it { to have_and_belong_to_many :users }
  expect_it { to validate_presence_of :name }
  expect_it { to validate_uniqueness_of :name }
  expect_it { to validate_presence_of :payload }

  it 'validates correct name' do
    should allow_value('comp_lex/na-me').for(:name)
    should_not allow_value('wrong\\path').for(:name)
    should_not allow_value('wrong//path').for(:name)
    should_not allow_value('/wrong/path').for(:name)
    should_not allow_value('wrong/path/').for(:name)
  end
end