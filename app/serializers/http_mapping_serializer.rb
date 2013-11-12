class HttpMappingSerializer < ActiveModel::Serializer
  include RecordFilter
  embed :ids
  attributes :id, :application_protocol, :url
  has_one :appliance, :port_mapping_template

  can_filter_by :appliance_id
end
