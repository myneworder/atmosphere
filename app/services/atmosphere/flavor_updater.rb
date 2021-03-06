# Populate the Atmosphere database with information regarding the
# available virtual machine flavors for each compute site.
module Atmosphere
  class FlavorUpdater
    def initialize(tenant)
      @tenant = tenant
    end

    def execute
      update_existing_flavors
      purge_non_existing_flavors
    rescue StandardError => e
      Rails.logger.error(I18n.t('virtual_machine_flavor.update_flavors_failed',
                                id: tenant.tenant_id, msg: e.message))
    end

    private

    attr_reader :tenant

    def purge_non_existing_flavors
      tenant.virtual_machine_flavors.
        where.not(id_at_site: cloud_flavors.map(&:id)).each do |flavor|
          if flavor.virtual_machines.count == 0
            flavor.destroy
          else
            flavor.active = false
            flavor.save!
          end
        end
    end

    def update_existing_flavors
      cloud_flavors.each { |flavor| update(flavor) }
    end

    def cloud_flavors
      @cloud_flavors ||= tenant.cloud_client.flavors
    end

    def update(cloud_flavor)
      tenant.virtual_machine_flavors.
        find_or_initialize_by(id_at_site: cloud_flavor.id).tap do |flavor|
          flavor.flavor_name = cloud_flavor.name
          flavor.cpu = cloud_flavor.vcpus
          flavor.memory = cloud_flavor.ram
          flavor.hdd = cloud_flavor.disk
          flavor.supported_architectures = cloud_flavor.supported_architectures
          calculate_price(flavor)

          unless flavor.save
            Rails.logger.error(I18n.t('virtual_machine_flavor.update_failed',
                                      name: cloud_flavor.name,
                                      error: flavor.errors))
          end
        end
    end

    include Atmosphere::FlavorUpdaterExt
  end
end
