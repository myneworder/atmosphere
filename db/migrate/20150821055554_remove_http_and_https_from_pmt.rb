class RemoveHttpAndHttpsFromPmt < ActiveRecord::Migration
  def change
    change_column_default(:atmosphere_port_mapping_templates,
                          :application_protocol, 'http')

    Atmosphere::PortMappingTemplate.where(application_protocol: 'http_https').
      joins(:http_mappings).find_each do |pmt|
        pmt.update_attribute(application_protocol: 'http')
        pmt.http_mappings.
          select { |mapping| mapping.application_protocol.https? }.
          each(&:destroy)
      end
  end
end
