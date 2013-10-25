class HttpMappingProxyConfGenerator
  # PN 2013-10-21
  # Generates data structure required by ProxyConf to set up redirections
  # for all VMs running on a given CloudSite.
  # Parameterized by cloud site ID

  def run(compute_site_id)

    begin
      cs = ComputeSite.find(compute_site_id)
    rescue ActiveRecord::RecordNotFound
      raise Air::UnknownComputeSite.new "Compute site with id #{compute_site_id.to_s} is unknown."
    end

    proxy_configuration = []

    appliances = Appliance.joins(:virtual_machines).where(virtual_machines: {compute_site: cs})

    appliances.each do |appliance|
      ips = appliance.virtual_machines.select(:ip).collect {|vm| vm.ip}
      pm_templates = appliance.appliance_type.port_mapping_templates
      pm_templates.each do |pmt|
        proxy_configuration << generate_redirection_and_port_mapping(appliance, pmt, ips, :http) if pmt.http?
        proxy_configuration << generate_redirection_and_port_mapping(appliance, pmt, ips, :https) if pmt.https?
      end
    end

    # vms.each do |vm|

    #   # Each VM may belong to multiple appliances
    #   appliances = vm.appliances

    #   if appliances.blank?
    #     logger.warn "VM with id #{vm.id} has no registered Appliances. This can happen if the VM was manually created using Nova interfaces (instead of being registered via VPH-Share UIs), but it can also indicate a schema integrity error. Please investigate."
    #   else

    #     appliances.each do |appl|

    #       # Each appliance may have multiple HTTP mappings
    #       http_mappings = appl.http_mappings
    #       http_mappings.each do |map|

    #         # Run schema validation (I'm being paranoid...)
    #         if map.port_mapping_template.blank?
    #           logger.error "HttpMapping with id #{map.id} has no matching PortMappingTemplate (expected exactly one)."
    #         elsif appl.appliance_set.blank?
    #           logger.error "Appliance with id #{appl.id} is not assigned to any ApplianceSet."
    #         elsif appl.appliance_configuration_instance.blank?
    #           logger.error "Appliance with id #{appl.id} has no matching ApplianceConfigurationInstance (expected exactly one)."
    #         else

    #           # Construct path object
    #           path = appl.appliance_set.id.to_s+'/'+appl.appliance_configuration_instance.id.to_s+'/'+map.port_mapping_template.id.to_s
    #           workers = []

    #           # Get all VMs for this appliance (this will produce duplicate records but is faster; we'll purge duplicates later)
    #           appl_vms = appl.virtual_machines
    #           appl.virtual_machines.each do |appl_vm|
    #             # Ignore if VM is not part of this compute site
    #             unless appl_vm.compute_site != cs
    #               workers << appl_vm.ip+":"+map.port_mapping_template.target_port.to_s
    #             end
    #           end

    #           # Spawn 0, 1 or 2 records for each mapping
    #           # (Depending on type - 0 for none, 1 for http or https, 2 for http_https)
    #           case map.port_mapping_template.application_protocol
    #           when 'none' then nil # Do nothing.
    #           when 'http' then
    #             proxy_configuration << {:path => path, :workers => workers, :type => 'http'}
    #           when 'https' then
    #             proxy_configuration << {:path => path, :workers => workers, :type => 'https'}
    #           when 'http_https' then
    #             proxy_configuration << {:path => path, :workers => workers, :type => 'http'}
    #             proxy_configuration << {:path => path, :workers => workers, :type => 'https'}
    #           else
    #             logger.error "Protocol type #{map.port_mapping_template.application_protocol} is not supported by Atmosphere."
    #             raise UnsupportedPortMappingProtocol "Protocol type #{map.port_mapping_template.application_protocol} is not supported by Atmosphere."
    #           end # End case statement
    #         end # End mapping schema validation
    #       end # End iteration over http mappings
    #     end # End iteration over appliances
    #   end # End if appliances.blank?
    # end # End iteration over VMs

    #proxy_configuration will contain duplicates when shared appliances are present, so...
    proxy_configuration.uniq

  end # End run(compute_site_id)

  private

  def generate_redirection_and_port_mapping(appliance, pmt, ips, type)
    redirection = redirection(appliance, pmt, ips, type)
    pm = appliance.http_mappings.find_or_create_by(port_mapping_template: pmt, application_protocol: type)
    pm.url = redirection[:path]
    unless pm.save
      logger.error "Unable to save port mapping for #{appliance.id} appliance, #{pmt.id} port mapping because of #{pm.errors.to_json}"
    end

    redirection
  end

  def redirection(appliance, pmt, ips, type)
    {
      path: "#{appliance.appliance_set.id}/#{appliance.appliance_configuration_instance.id}/#{pmt.service_name}",
      workers: ips.collect { |ip| "#{ip}:#{pmt.target_port}"},
      type: type
    }
  end

end