#
# Cookbook Name:: openstack-image
# Attributes:: default
#
# Copyright 2012, Rackspace US, Inc.
# Copyright 2013, Craig Tracey <craigtracey@gmail.com>
# Copyright 2013, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Set to some text value if you want templated config files
# to contain a custom banner at the top of the written file
default["openstack"]["image"]["custom_template_banner"] = "
# This file autogenerated by Chef
# Do not edit, changes will be overwritten
"

default["openstack"]["image"]["verbose"] = "False"
default["openstack"]["image"]["debug"] = "False"
# This is the name of the Chef role that will install the Keystone Service API
default["openstack"]["image"]["identity_service_chef_role"] = "os-identity"

# Gets set in the Image Endpoint when registering with Keystone
default["openstack"]["image"]["region"] = "RegionOne"

default["openstack"]["image"]["db"]["username"] = "glance"

default["openstack"]["image"]["service_tenant_name"] = "service"
default["openstack"]["image"]["service_user"] = "glance"
default["openstack"]["image"]["service_role"] = "admin"

# Keystone PKI signing directories
# XXX keystoneclient wants these dirs to exist even if it doesn't use them
default["openstack"]["image"]["api"]["auth"]["cache_dir"] = "/var/cache/glance/api"
default["openstack"]["image"]["registry"]["auth"]["cache_dir"] = "/var/cache/glance/registry"

default["openstack"]["image"]["api"]["default_store"] = "file"
# If set, glance API service will bind to the address on this interface,
# otherwise it will bind to the API endpoint's host.
default["openstack"]["image"]["api"]["bind_interface"] = nil
default["openstack"]["image"]["api"]["swift"]["container"] = "glance"
default["openstack"]["image"]["api"]["swift"]["large_object_size"] = "200"
default["openstack"]["image"]["api"]["swift"]["large_object_chunk_size"] = "200"
default["openstack"]["image"]["api"]["cache"]["image_cache_max_size"] = "10737418240"

# Ceph Options
default["openstack"]["image"]["api"]["rbd"]["rbd_store_ceph_conf"] = "/etc/ceph/ceph.conf"
default["openstack"]["image"]["api"]["rbd"]["rbd_store_user"] = "glance"
default["openstack"]["image"]["api"]["rbd"]["rbd_store_pool"] = "images"
default["openstack"]["image"]["api"]["rbd"]["rbd_store_chunk_size"] = "8"


# If set, glance registry service will bind to the address on this interface,
# otherwise it will bind to the API endpoint's host.
default["openstack"]["image"]["registry"]["bind_interface"] = nil

# Default Image Locations
default["openstack"]["image"]["image_upload"] = false
default["openstack"]["image"]["upload_images"] = [ "cirros" ]
default["openstack"]["image"]["upload_image"]["precise"] = "http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-amd64-disk1.img"
default["openstack"]["image"]["upload_image"]["oneiric"] = "http://cloud-images.ubuntu.com/oneiric/current/oneiric-server-cloudimg-amd64-disk1.img"
default["openstack"]["image"]["upload_image"]["natty"] = "http://cloud-images.ubuntu.com/natty/current/natty-server-cloudimg-amd64-disk1.img"
default["openstack"]["image"]["upload_image"]["cirros"] = "https://launchpadlibrarian.net/83305348/cirros-0.3.0-x86_64-disk.img"
# more images available at https://github.com/rackerjoe/oz-image-build
default["openstack"]["image"]["upload_image"]["centos"] = "http://c250663.r63.cf1.rackcdn.com/centos60_x86_64.qcow2"

# logging attribute
default["openstack"]["image"]["syslog"]["use"] = false
default["openstack"]["image"]["syslog"]["facility"] = "LOG_LOCAL2"
default["openstack"]["image"]["syslog"]["config_facility"] = "local2"

# platform-specific settings
case platform
when "fedora", "redhat", "centos" # :pragma-foodcritic: ~FC024 - won't fix this
  default["openstack"]["image"]["user"] = "glance"
  default["openstack"]["image"]["group"] = "glance"
  default["openstack"]["image"]["platform"] = {
    "postgresql_python_packages" => [ "python-psycopg2" ],
    "mysql_python_packages" => [ "MySQL-python" ],
    "image_packages" => [ "openstack-glance", "openstack-swift", "cronie" ],
    "image_api_service" => "openstack-glance-api",
    "image_registry_service" => "openstack-glance-registry",
    "image_api_process_name" => "glance-api",
    "package_overrides" => ""
  }
when "suse"
  default["openstack"]["image"]["user"] = "openstack-glance"
  default["openstack"]["image"]["group"] = "openstack-glance"
  default["openstack"]["image"]["platform"] = {
    "postgresql_python_packages" => [ "python-psycopg2" ],
    "mysql_python_packages" => [ "python-mysql" ],
    "image_packages" => [ "openstack-glance", "openstack-swift", "python-glanceclient" ],
    "image_api_service" => "openstack-glance-api",
    "image_registry_service" => "openstack-glance-registry",
    "image_api_process_name" => "glance-api",
    "package_overrides" => ""
  }
when "ubuntu"
  default["openstack"]["image"]["user"] = "glance"
  default["openstack"]["image"]["group"] = "glance"
  default["openstack"]["image"]["platform"] = {
    "postgresql_python_packages" => [ "python-psycopg2" ],
    "mysql_python_packages" => [ "python-mysqldb" ],
    "image_packages" => [ "glance", "python-swift" ],
    "image_api_service" => "glance-api",
    "image_registry_service" => "glance-registry",
    "image_registry_process_name" => "glance-registry",
    "package_overrides" => "-o Dpkg::Options::='--force-confold' -o Dpkg::Options::='--force-confdef'"
  }
end
