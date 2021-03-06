# encoding: UTF-8
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
default['openstack']['image']['custom_template_banner'] = '
# This file autogenerated by Chef
# Do not edit, changes will be overwritten
'

default['openstack']['image']['verbose'] = 'False'
default['openstack']['image']['debug'] = 'False'
# This is the name of the Chef role that will install the Keystone Service API
default['openstack']['image']['identity_service_chef_role'] = 'os-identity'

# Gets set in the Image Endpoint when registering with Keystone
default['openstack']['image']['region'] = 'RegionOne'

# The name of the Chef role that knows about the message queue server
# that Glance uses
default['openstack']['image']['rabbit_server_chef_role'] = 'os-ops-messaging'

default['openstack']['image']['db']['username'] = 'glance'
# Execute database migrations.  There are cases where migrations should not be
# executed.  For example when upgrading a zone, and the image database is
# replicated across many zones.
default['openstack']['image']['db']['migrate'] = true

# This user's password is stored in an encrypted databag
# and accessed with openstack-common cookbook library's
# get_password routine.  You are expected to create
# the user, pass, vhost in a wrapper rabbitmq cookbook.
default['openstack']['image']['rabbit']['username'] = 'guest'
default['openstack']['image']['rabbit']['vhost'] = '/'
default['openstack']['image']['rabbit']['port'] = 5672
default['openstack']['image']['rabbit']['host'] = '127.0.0.1'

# MQ options
default['openstack']['image']['mq']['service_type'] = node['openstack']['mq']['service_type']
default['openstack']['image']['mq']['notifier_strategy'] = 'noop'
default['openstack']['image']['mq']['qpid']['host'] = '127.0.0.1'
default['openstack']['image']['mq']['qpid']['port'] = '5672'
default['openstack']['image']['mq']['qpid']['qpid_hosts'] = ['127.0.0.1:5672']

default['openstack']['image']['mq']['qpid']['username'] = ''
default['openstack']['image']['mq']['qpid']['password'] = ''
default['openstack']['image']['mq']['qpid']['sasl_mechanisms'] = ''
default['openstack']['image']['mq']['qpid']['reconnect'] = true
default['openstack']['image']['mq']['qpid']['reconnect_timeout'] = 0
default['openstack']['image']['mq']['qpid']['reconnect_limit'] = 0
default['openstack']['image']['mq']['qpid']['reconnect_interval_min'] = 0
default['openstack']['image']['mq']['qpid']['reconnect_interval_max'] = 0
default['openstack']['image']['mq']['qpid']['reconnect_interval'] = 0
default['openstack']['image']['mq']['qpid']['heartbeat'] = 60
default['openstack']['image']['mq']['qpid']['protocol'] = 'tcp'
default['openstack']['image']['mq']['qpid']['tcp_nodelay'] = true

default['openstack']['image']['service_tenant_name'] = 'service'
default['openstack']['image']['service_user'] = 'glance'
default['openstack']['image']['service_role'] = 'admin'

# Setting this to v2.0. See discussion on
# https://bugs.launchpad.net/openstack-chef/+bug/1207504
default['openstack']['image']['api']['auth']['version'] = 'v2.0'

# Keystone PKI signing directories
# XXX keystoneclient wants these dirs to exist even if it doesn't use them
default['openstack']['image']['api']['auth']['cache_dir'] = '/var/cache/glance/api'
default['openstack']['image']['registry']['auth']['cache_dir'] = '/var/cache/glance/registry'

# Whether to use any of the default caching pipelines from the paste configuration file
default['openstack']['image']['api']['caching'] = false
default['openstack']['image']['api']['cache_management'] = false

default['openstack']['image']['api']['default_store'] = 'file'

default['openstack']['image']['filesystem_store_datadir'] = '/var/lib/glance/images'

# If set, glance API service will bind to the address on this interface,
# otherwise it will bind to the API endpoint's host.
default['openstack']['image']['api']['bind_interface'] = nil
default['openstack']['image']['api']['swift']['container'] = 'glance'
default['openstack']['image']['api']['swift']['large_object_size'] = '200'
default['openstack']['image']['api']['swift']['large_object_chunk_size'] = '200'
default['openstack']['image']['api']['cache']['image_cache_max_size'] = '10737418240'

# Directory for the Image Cache
default['openstack']['image']['cache']['dir'] = '/var/lib/glance/image-cache/'
# Number of seconds until an incomplete image is considered stalled an
# eligible for reaping
default['openstack']['image']['cache']['stall_time'] = 86_400
# Number of seconds to leave invalid images around before they are eligible to be reaped
default['openstack']['image']['cache']['grace_period'] = 3600

# Ceph Options
default['openstack']['image']['api']['rbd']['rbd_store_ceph_conf'] = '/etc/ceph/ceph.conf'
default['openstack']['image']['api']['rbd']['rbd_store_user'] = 'glance'
default['openstack']['image']['api']['rbd']['rbd_store_pool'] = 'images'
default['openstack']['image']['api']['rbd']['rbd_store_chunk_size'] = '8'

# If set, glance registry service will bind to the address on this interface,
# otherwise it will bind to the API endpoint's host.
default['openstack']['image']['registry']['bind_interface'] = nil

# API to use for accessing data. Default value points to sqlalchemy
# package.
default['openstack']['image']['data_api'] = 'glance.db.sqlalchemy.api'

# Default Image Locations
default['openstack']['image']['upload_images'] = ['cirros']
default['openstack']['image']['upload_image']['precise'] = 'http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-amd64-disk1.img'
default['openstack']['image']['upload_image']['oneiric'] = 'http://cloud-images.ubuntu.com/oneiric/current/oneiric-server-cloudimg-amd64-disk1.img'
default['openstack']['image']['upload_image']['natty'] = 'http://cloud-images.ubuntu.com/natty/current/natty-server-cloudimg-amd64-disk1.img'
default['openstack']['image']['upload_image']['cirros'] = 'https://launchpadlibrarian.net/83305348/cirros-0.3.0-x86_64-disk.img'
# more images available at https://github.com/rackerjoe/oz-image-build
default['openstack']['image']['upload_image']['centos'] = 'http://c250663.r63.cf1.rackcdn.com/centos60_x86_64.qcow2'

# logging attribute
default['openstack']['image']['syslog']['use'] = false
default['openstack']['image']['syslog']['facility'] = 'LOG_LOCAL2'
default['openstack']['image']['syslog']['config_facility'] = 'local2'

# cron output redirection
default['openstack']['image']['cron']['redirection'] = '> /dev/null 2>&1'

# platform-specific settings
case platform
when 'fedora', 'redhat', 'centos' # :pragma-foodcritic: ~FC024 - won't fix this
  default['openstack']['image']['user'] = 'glance'
  default['openstack']['image']['group'] = 'glance'
  default['openstack']['image']['platform'] = {
    'postgresql_python_packages' => ['python-psycopg2'],
    'mysql_python_packages' => ['MySQL-python'],
    'db2_python_packages' => ['db2-odbc', 'python-ibm-db', 'python-ibm-db-sa'],
    'image_packages' => ['openstack-glance', 'cronie', 'python-glanceclient'],
    'image_client_packages' => ['python-glanceclient'],
    'swift_packages' => ['openstack-swift'],
    'image_api_service' => 'openstack-glance-api',
    'image_registry_service' => 'openstack-glance-registry',
    'image_api_process_name' => 'glance-api',
    'package_overrides' => ''
  }
when 'suse'
  default['openstack']['image']['user'] = 'openstack-glance'
  default['openstack']['image']['group'] = 'openstack-glance'
  default['openstack']['image']['platform'] = {
    'postgresql_python_packages' => ['python-psycopg2'],
    'mysql_python_packages' => ['python-mysql'],
    'image_packages' => ['openstack-glance', 'python-glanceclient'],
    'image_client_packages' => ['python-glanceclient'],
    'swift_packages' => ['openstack-swift'],
    'image_api_service' => 'openstack-glance-api',
    'image_registry_service' => 'openstack-glance-registry',
    'image_api_process_name' => 'glance-api',
    'package_overrides' => ''
  }
when 'ubuntu'
  default['openstack']['image']['user'] = 'glance'
  default['openstack']['image']['group'] = 'glance'
  default['openstack']['image']['platform'] = {
    'postgresql_python_packages' => ['python-psycopg2'],
    'mysql_python_packages' => ['python-mysqldb'],
    'image_packages' => ['glance'],
    'image_client_packages' => ['python-glanceclient'],
    'swift_packages' => ['python-swift'],
    'image_api_service' => 'glance-api',
    'image_registry_service' => 'glance-registry',
    'image_registry_process_name' => 'glance-registry',
    'package_overrides' => "-o Dpkg::Options::='--force-confold' -o Dpkg::Options::='--force-confdef'"
  }
end
