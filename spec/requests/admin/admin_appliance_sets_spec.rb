require 'spec_helper'

describe "Admin::ApplianceSets" do
  describe "GET /admin_appliance_sets" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get admin_appliance_sets_path
      expect(response.status).to eq 200
    end
  end
end
