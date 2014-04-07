require 'fog/openstack/compute'
require 'fog/openstack/models/compute/server'
require 'fog/aws/compute'
require 'fog/aws/models/compute/flavor'
require 'fog/openstack/models/compute/flavor'
require 'fog/aws/models/compute/image'
require 'fog/openstack/models/compute/image'
require 'fog/aws/models/compute/server'


# open stack client does not provide import_key_pair method
# while aws does
# It is desired that both aws and openstack client provide identical api hence the magic :-)
class Fog::Compute::OpenStack::Real
  def import_key_pair(name, public_key)
    create_key_pair(name, public_key)
  end

  # alias does not work since create_key_pair method is also added using magic
  # alias :import_key_pair :create_key_pair

  # AWS and openstack create_image methods have different signatures...
  def save_template(instance_id, tmpl_name)
    resp = create_image(instance_id, tmpl_name)
    if resp.status == 200
      resp.body['image']['id']
    else
      # TODO raise specific exc
      raise "Failed to save vm #{instance_id} as template"
    end
  end
end

class Fog::Compute::OpenStack::Flavor
  def supported_architectures
    'x86_64'
  end
end

class Fog::Compute::OpenStack::Server

  def image_id
    image['id']
  end

  def task_state
    os_ext_sts_task_state
  end
end

class Fog::Compute::AWS::Real
  def save_template(instance_id, tmpl_name)
    resp = create_image(instance_id, tmpl_name, nil)
    if resp.status == 200
      resp.body['imageId']
    else
      # TODO raise specific exc
      raise "Failed to save vm #{instance_id} as template"
    end
  end
  def reboot_server(server_id)
    reboot_instances([server_id])
  end
end

class Fog::Compute::AWS::Server

  def flavor
    # Return a hash with only flavor ID defined (mimics OpenStack behavior)
    # Note: would normally return a Fog::Compute::AWS::Flavor object
    {'id' => flavor_id}
  end

  def name
    tags['Name']
  end

  def task_state
    nil #TODO
  end
end

class Fog::Compute::OpenStack::Image
  def architecture
    'x86_64'
  end
end

# Image class does not implement destroy method
class Fog::Compute::AWS::Image
  def destroy
    deregister
  end

  def status
    # possible states of an image in EC2: available, pending, failed
    # this maps to: active, saving and error
    case state
    when 'available'
      'active'
    when 'pending'
      'saving'
    else
      'error'
    end
  end
end

# Flavor unification classes
# Mimic OpenStack
class Fog::Compute::AWS::Flavor
  def vcpus
    cores
  end

  def supported_architectures
    case bits
    when 0
      'i386_and_x86_64'
    when 32
      'i386_and_x86_64'
    else 'x86_64'
    end
  end
end