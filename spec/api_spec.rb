# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-image::api' do
  before { image_stubs }
  describe 'ubuntu' do
    before do
      @chef_run = ::ChefSpec::Runner.new ::UBUNTU_OPTS do |n|
        n.set['openstack']['image']['syslog']['use'] = true
        n.set['cpu'] = { 'total' => '1' }
      end
      @chef_run.converge 'openstack-image::api'
    end

    expect_runs_openstack_common_logging_recipe

    it 'does not run logging recipe' do
      chef_run = ::ChefSpec::Runner.new ::UBUNTU_OPTS
      chef_run.converge 'openstack-image::api'

      expect(chef_run).not_to include_recipe 'openstack-common::logging'
    end

    it 'does not install swift packages' do
      expect(@chef_run).not_to upgrade_package 'python-swift'
    end

    it 'has configurable default_store setting for swift' do
      chef_run = ::ChefSpec::Runner.new ::UBUNTU_OPTS do |n|
        n.set['openstack']['image']['api']['default_store'] = 'swift'
      end
      chef_run.converge 'openstack-image::api'

      expect(chef_run).to upgrade_package 'python-swift'
    end

    expect_installs_python_keystone

    expect_installs_curl

    expect_installs_ubuntu_glance_packages

    it 'starts glance api on boot' do
      expect(@chef_run).to enable_service('glance-api')
    end

    expect_creates_glance_dir

    expect_creates_cache_dir

    describe 'policy.json' do
      before do
        @file = @chef_run.template '/etc/glance/policy.json'
      end

      it 'has proper owner' do
        expect(@file.owner).to eq('glance')
        expect(@file.group).to eq('glance')
      end

      it 'has proper modes' do
        expect(sprintf('%o', @file.mode)).to eq '644'
      end

      it 'notifies image-api restart' do
        expect(@file).to notify('service[image-api]').to(:restart)
      end
    end

    describe 'glance-api.conf' do
      before do
        @file = @chef_run.template '/etc/glance/glance-api.conf'
      end

      it 'has proper owner' do
        expect(@file.owner).to eq('glance')
        expect(@file.group).to eq('glance')
      end

      it 'has proper modes' do
        expect(sprintf('%o', @file.mode)).to eq '644'
      end

      it 'has bind host when bind_interface not specified' do
        match = 'bind_host = 127.0.0.1'
        expect(@chef_run).to render_file(@file.name).with_content(match)
      end

      it 'has bind host when bind_interface specified' do
        chef_run = ::ChefSpec::Runner.new ::UBUNTU_OPTS do |n|
          n.set['openstack']['image']['api']['bind_interface'] = 'lo'
          n.set['cpu'] = { 'total' => '1' }
        end
        chef_run.converge 'openstack-image::api'

        match = 'bind_host = 127.0.1.1'
        expect(chef_run).to render_file(@file.name).with_content(match)
      end

      it 'has default filesystem_store_datadir setting' do

        match = 'filesystem_store_datadir = /var/lib/glance/images'
        expect(@chef_run).to render_file(@file.name).with_content(match)
      end

      it 'has configurable filesystem_store_datadir setting' do
        chef_run = ::ChefSpec::Runner.new ::UBUNTU_OPTS do |n|
          n.set['openstack']['image']['filesystem_store_datadir'] = 'foo'
          n.set['cpu'] = { 'total' => '1' }
        end
        chef_run.converge 'openstack-image::api'

        expect(chef_run).to render_file(@file.name).with_content(
          /^filesystem_store_datadir = foo$/)
      end

      it 'notifies image-api restart' do
        expect(@file).to notify('service[image-api]').to(:restart)
      end

      it 'does not have caching enabled by default' do
        expect(@chef_run).to render_file(@file.name).with_content(
          /^flavor = keystone$/)
      end

      it 'enables caching when attribute is set' do
        chef_run = ::ChefSpec::Runner.new ::UBUNTU_OPTS do |n|
          n.set['openstack']['image']['api']['caching'] = true
          n.set['cpu'] = { 'total' => '1' }
        end
        chef_run.converge 'openstack-image::api'

        expect(chef_run).to render_file(@file.name).with_content(
          /^flavor = keystone\+caching$/)
      end

      it 'enables cache_management when attribute is set' do
        chef_run = ::ChefSpec::Runner.new ::UBUNTU_OPTS do |n|
          n.set['openstack']['image']['api']['cache_management'] = true
          n.set['cpu'] = { 'total' => '1' }
        end
        chef_run.converge 'openstack-image::api'

        expect(chef_run).to render_file(@file.name).with_content(
          /^flavor = keystone\+cachemanagement$/)
      end

      it 'enables only cache_management when it and the caching attributes are set' do
        chef_run = ::ChefSpec::Runner.new ::UBUNTU_OPTS do |n|
          n.set['openstack']['image']['api']['cache_management'] = true
          n.set['openstack']['image']['api']['caching'] = true
          n.set['cpu'] = { 'total' => '1' }
        end
        chef_run.converge 'openstack-image::api'

        expect(chef_run).to render_file(@file.name).with_content(
          /^flavor = keystone\+cachemanagement$/)
      end
    end

    describe 'qpid' do
      before do
        @file = @chef_run.template '/etc/glance/glance-api.conf'
        @chef_run.node.set['openstack']['image']['mq']['service_type'] = 'qpid'
      end

      it 'has qpid_hostname' do
        match = 'qpid_hostname=127.0.0.1'
        expect(@chef_run).to render_file(@file.name).with_content(match)
      end

      it 'has qpid_port' do
        match = 'qpid_port=5672'
        expect(@chef_run).to render_file(@file.name).with_content(match)
      end

      it 'has qpid_username' do
        match = 'qpid_username='
        expect(@chef_run).to render_file(@file.name).with_content(match)
      end

      it 'has qpid_password' do
        match = 'qpid_password='
        expect(@chef_run).to render_file(@file.name).with_content(match)
      end

      it 'has qpid_sasl_mechanisms' do
        match = 'qpid_sasl_mechanisms='
        expect(@chef_run).to render_file(@file.name).with_content(match)
      end

      it 'has qpid_reconnect' do
        match = 'qpid_reconnect=true'
        expect(@chef_run).to render_file(@file.name).with_content(match)
      end

      it 'has qpid_reconnect_timeout' do
        match = 'qpid_reconnect_timeout=0'
        expect(@chef_run).to render_file(@file.name).with_content(match)
      end

      it 'has qpid_reconnect_limit' do
        match = 'qpid_reconnect_limit=0'
        expect(@chef_run).to render_file(@file.name).with_content(match)
      end

      it 'has qpid_reconnect_interval_min' do
        match = 'qpid_reconnect_interval_min=0'
        expect(@chef_run).to render_file(@file.name).with_content(match)
      end

      it 'has qpid_reconnect_interval_max' do
        match = 'qpid_reconnect_interval_max=0'
        expect(@chef_run).to render_file(@file.name).with_content(match)
      end

      it 'has qpid_reconnect_interval' do
        match = 'qpid_reconnect_interval=0'
        expect(@chef_run).to render_file(@file.name).with_content(match)
      end

      it 'has qpid_heartbeat' do
        match = 'qpid_heartbeat=60'
        expect(@chef_run).to render_file(@file.name).with_content(match)
      end

      it 'has qpid_protocol' do
        match = 'qpid_protocol=tcp'
        expect(@chef_run).to render_file(@file.name).with_content(match)
      end

      it 'has qpid_tcp_nodelay' do
        match = 'qpid_tcp_nodelay=true'
        expect(@chef_run).to render_file(@file.name).with_content(match)
      end
    end

    describe 'glance-api-paste.ini' do
      before do
        @file = @chef_run.template '/etc/glance/glance-api-paste.ini'
      end

      it 'has proper owner' do
        expect(@file.owner).to eq('glance')
        expect(@file.group).to eq('glance')
      end

      it 'has proper modes' do
        expect(sprintf('%o', @file.mode)).to eq '644'
      end

      it 'template contents' do
        pending 'TODO: implement'
      end

      it 'notifies image-api restart' do
        expect(@file).to notify('service[image-api]').to(:restart)
      end
    end

    describe 'glance-cache.conf' do
      before do
        @file = @chef_run.template '/etc/glance/glance-cache.conf'
      end

      it 'has proper owner' do
        expect(@file.owner).to eq('glance')
        expect(@file.group).to eq('glance')
      end

      it 'has proper modes' do
        expect(sprintf('%o', @file.mode)).to eq '644'
      end

      it 'template contents' do
        pending 'TODO: implement'
      end

      it 'notifies image-api restart' do
        expect(@file).to notify('service[image-api]').to(:restart)
      end

      it 'has the default image_cache_dir setting' do
        expect(@chef_run).to render_file(@file.name).with_content(
          %r{^image_cache_dir = /var/lib/glance/image-cache/$})
      end

      it 'has a configurable image_cache_dir setting' do
        chef_run = ::ChefSpec::Runner.new ::UBUNTU_OPTS do |n|
          n.set['openstack']['image']['cache']['dir'] = 'foo'
          n.set['cpu'] = { 'total' => '1' }
        end
        chef_run.converge 'openstack-image::api'

        expect(chef_run).to render_file(@file.name).with_content(
          /^image_cache_dir = foo$/)
      end

      it 'has the default cache stall_time setting' do
        expect(@chef_run).to render_file(@file.name).with_content(
          /^image_cache_stall_time = 86400$/)
      end

      it 'has a configurable stall_time setting' do
        chef_run = ::ChefSpec::Runner.new ::UBUNTU_OPTS do |n|
          n.set['openstack']['image']['cache']['stall_time'] = '42'
          n.set['cpu'] = { 'total' => '1' }
        end
        chef_run.converge 'openstack-image::api'

        expect(chef_run).to render_file(@file.name).with_content(
          /^image_cache_stall_time = 42$/)
      end

      it 'has the default grace_period setting' do
        expect(@chef_run).to render_file(@file.name).with_content(
          /^image_cache_invalid_entry_grace_period = 3600$/)
      end

      it 'has a configurable grace_period setting' do
        chef_run = ::ChefSpec::Runner.new ::UBUNTU_OPTS do |n|
          n.set['openstack']['image']['cache']['grace_period'] = '42'
          n.set['cpu'] = { 'total' => '1' }
        end
        chef_run.converge 'openstack-image::api'

        expect(chef_run).to render_file(@file.name).with_content(
          /^image_cache_invalid_entry_grace_period = 42$/)
      end
    end

    describe 'glance-cache-paste.ini' do
      before do
        @file = @chef_run.template '/etc/glance/glance-cache-paste.ini'
      end

      it 'has proper owner' do
        expect(@file.owner).to eq('glance')
        expect(@file.group).to eq('glance')
      end

      it 'has proper modes' do
        expect(sprintf('%o', @file.mode)).to eq '644'
      end

      it 'template contents' do
        pending 'TODO: implement'
      end

      it 'notifies image-api restart' do
        expect(@file).to notify('service[image-api]').to(:restart)
      end
    end

    describe 'glance-scrubber.conf' do
      before do
        @file = @chef_run.template '/etc/glance/glance-scrubber.conf'
      end

      it 'has proper owner' do
        expect(@file.owner).to eq('glance')
        expect(@file.group).to eq('glance')
      end

      it 'has proper modes' do
        expect(sprintf('%o', @file.mode)).to eq '644'
      end

      it 'template contents' do
        pending 'TODO: implement'
      end
    end

    it 'has glance-cache-pruner cronjob running every 30 minutes' do
      cron = @chef_run.cron 'glance-cache-pruner'

      expect(cron.command).to eq '/usr/bin/glance-cache-pruner > /dev/null 2>&1'
      expect(cron.minute).to eq '*/30'
    end

    it 'has glance-cache-cleaner to run at 00:01 each day' do
      cron = @chef_run.cron 'glance-cache-cleaner'

      expect(cron.command).to eq '/usr/bin/glance-cache-cleaner > /dev/null 2>&1'
      expect(cron.minute).to eq '01'
      expect(cron.hour).to eq '00'
    end

    describe 'glance-scrubber-paste.ini' do
      before do
        @file = @chef_run.template '/etc/glance/glance-scrubber-paste.ini'
      end

      it 'has proper owner' do
        expect(@file.owner).to eq('glance')
        expect(@file.group).to eq('glance')
      end

      it 'has proper modes' do
        expect(sprintf('%o', @file.mode)).to eq '644'
      end

      it 'template contents' do
        pending 'TODO: implement'
      end
    end
  end
end
