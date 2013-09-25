admin = User.create(login: 'admin', full_name: 'Root Admiński z Superuserów', email: 'admin@localhost.pl', password: 'airtraffic123', password_confirmation: 'airtraffic123', authentication_token: 'secret', roles: [:admin, :developer])

as = ApplianceSet.create(name: 'test appliance set', user: admin)

at = ApplianceType.create(name: 'Ubuntu Ruliez, hy hy')

at2 = ApplianceType.create(name: 'ArchLinux')

PortMappingTemplate.create(service_name: 'pmt', target_port: 1, application_protocol: 'http', transport_protocol: 'tcp', appliance_type: at)

act = ApplianceConfigurationTemplate.create(name: 'act', appliance_type: at)

act2 = ApplianceConfigurationTemplate.create(name: 'act2', appliance_type: at2)

aci = ApplianceConfigurationInstance.create(appliance_configuration_template: act)

aci2 = ApplianceConfigurationInstance.create(appliance_configuration_template: act2)

Appliance.create(appliance_set: as, appliance_type: at, appliance_configuration_instance: aci)

Appliance.create(appliance_set: as, appliance_type: at2, appliance_configuration_instance: aci2)

ComputeSite.create(site_id: "cyfronet-folsom", name: "Cyfronet", location: "Cracow", site_type: "private", technology: "openstack")

ComputeSite.create(site_id: "amazon-eu", name: "Amazon EU", location: "Ireland", site_type: "public", technology: "aws")