require 'rails_helper'

describe OptimizationStrategy::Default do

  before do
    Fog.mock!
  end

  context '#can_reuse_vm?' do

    it 'reuses shared VMs in prod mode' do
      appl = appliance(development: false, shared: true)
      subject = OptimizationStrategy::Default.new(appl)

      expect(subject.can_reuse_vm?).to be_truthy
    end

    it 'does not reuse VM in dev mode' do
      appl = appliance(development: true, shared: true)
      subject = OptimizationStrategy::Default.new(appl)

      expect(subject.can_reuse_vm?).to be_falsy
    end

    it 'does not reuse not shareable VMs' do
      appl = appliance(development: false, shared: false)
      subject = OptimizationStrategy::Default.new(appl)

      expect(subject.can_reuse_vm?).to be_falsy
    end
  end

  def appliance(options)
    double(
      development?: options[:development],
      appliance_type: double(shared: options[:shared])
    )
  end

  let!(:wf) { create(:workflow_appliance_set) }
  let!(:wf2) { create(:workflow_appliance_set) }
  let!(:openstack) { create(:openstack_with_flavors, funds: [fund]) }
  let!(:fund) { create(:fund) }
  let!(:shareable_appl_type) { create(:shareable_appliance_type) }
  let!(:tmpl_of_shareable_at) { create(:virtual_machine_template, appliance_type: shareable_appl_type, compute_site: openstack)}

  context 'new appliance created' do

    context 'development mode' do

      let(:dev_appliance_set) { create(:dev_appliance_set) }
      let(:config_inst) { create(:appliance_configuration_instance) }
      it 'does not allow to reuse vm for dev appliance' do
        tmpl_of_shareable_at
        appl1 = create(:appliance, appliance_set: wf, appliance_type: shareable_appl_type, appliance_configuration_instance: config_inst, fund: fund, compute_sites: ComputeSite.all)
        appl2 = Appliance.new(appliance_set: dev_appliance_set, appliance_type: shareable_appl_type, appliance_configuration_instance: config_inst, fund: fund, compute_sites: ComputeSite.all)
        subject = OptimizationStrategy::Default.new(appl2)
        expect(subject.can_reuse_vm?).to be_falsy
      end

      it 'does not reuse available vm if it is in dev mode' do
        tmpl_of_shareable_at
        appl1 = create(:appliance, appliance_set: dev_appliance_set, appliance_type: shareable_appl_type, appliance_configuration_instance: config_inst, fund: fund, compute_sites: ComputeSite.all)
        appl2 = Appliance.new(appliance_set: wf2, appliance_type: shareable_appl_type, appliance_configuration_instance: config_inst, fund: fund, compute_sites: ComputeSite.all)
        subject = OptimizationStrategy::Default.new(appl2)
        expect(subject.vm_to_reuse).to be nil
      end

    end

  end

end