class PortMappingTemplateSerializer < ActiveModel::Serializer
  embed :ids

  attributes :id, :transport_protocol, :application_protocol, :service_name, :target_port

  has_one :appliance_type, key: :appliance_type
  has_one :dev_mode_property_set, key: :dev_mode_property_set
end
