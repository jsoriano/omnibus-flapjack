require 'serverspec_spec_helper'

describe service('redis-flapjack'), :if => os[:family] == 'ubuntu' do
  it { should be_enabled }
end

describe service('redis-flapjack'), :if => os[:family] == 'redhat' do
  it { should_not be_enabled }
end

describe service('flapjack'), :if => os[:family] == 'ubuntu' do
  it { should be_enabled }
end

describe service('flapjack'), :if => os[:family] == 'redhat' do
  it { should_not be_enabled }
end

describe package('flapjack') do
  it { should be_installed }
end

describe service('flapjack') do
  it { should be_running }
end

describe process("redis-server") do
  it { should be_running }
  its(:args) { should match /0.0.0.0:6380/ }
end

describe process("flapjack") do
  it { should be_running }
  its(:args) { should match   /\/opt\/flapjack\/bin\/flapjack server start/ }
end

describe port(3080) do
  it { should be_listening }
end

describe port(3081) do
  it { should be_listening }
end

describe port(6380) do
  it { should be_listening }
end

describe command('/opt/flapjack/bin/flapjack receiver httpbroker --help') do
  its(:stdout) { should match /port/ }
  its(:stdout) { should match /server/ }
  its(:stdout) { should match /database/ }
  its(:stdout) { should match /interval/ }
end

describe file('/etc/flapjack/flapjack_config.yaml') do
  it { should be_file }
  its(:content) { should match /pagerduty/ }
end

describe file('/usr/local/lib/flapjackfeeder.o') do
  it { should be_file }
end

describe file('/var/log/flapjack/flapjack.log') do
  it { should be_file }
  it { should be_mode 644 }
end

describe file('/var/log/flapjack/notification.log') do
  it { should be_file }
  it { should be_mode 644 }
end

describe file('/var/log/flapjack/jsonapi_access.log') do
  it { should be_file }
  it { should be_mode 644 }
end

describe file('/var/log/flapjack/redis-flapjack.log') do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'flapjack' }
  it { should be_grouped_into 'flapjack' }
end

describe file('/var/log/flapjack/web_access.log') do
  it { should be_file }
  it { should be_mode 644 }
end
