describe package('fluent-bit') do
  it { should be_installed }
end

describe systemd_service('fluent-bit') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe file('/etc/sysconfig/fluent-bit') do
  it { should exist }
  its('content') { should match /OBSERVE_HOST=/ }
  its('content') { should match /OBSERVE_TOKEN=/ }
end

describe file('/etc/fluent-bit/fluent-bit.conf') do
  it { should exist }
end

describe file('/etc/fluent-bit/observe_custom.conf') do
  it { should exist }
end

describe file('/etc/fluent-bit/observe_metrics.conf') do
  it { should exist }
end

describe file('/etc/fluent-bit/observe_logs.conf') do
  it { should exist }
end

describe package('telegraf') do
  it { should be_installed }
end

describe systemd_service('telegraf') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe file('/etc/default/telegraf') do
  it { should exist }
  its('content') { should match /OBSERVE_HOST=/ }
  its('content') { should match /OBSERVE_TOKEN=/ }
end

describe file('/etc/telegraf/telegraf.conf') do
  it { should exist }
end

describe file('/etc/telegraf/observe_custom.conf') do
  it { should exist }
end

describe file('/etc/telegraf/observe_metrics.conf') do
  it { should exist }
end

describe file('/etc/telegraf/observe_logs.conf') do
  it { should exist }
end