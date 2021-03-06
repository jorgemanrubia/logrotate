#
# Cookbook Name:: logrotate
# Definition:: logrotate_instance
#
# Copyright 2009, Scott M. Likens
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

define :logrotate_app, :enable => true, :frequency => "weekly", :template => "logrotate.erb", :cookbook => "logrotate", :postrotate => nil, :prerotate => nil, :firstaction => nil, :lastaction => nil, :sharedscripts => false do
  include_recipe "logrotate"

  acceptable_options = ['missingok', 'compress', 'delaycompress', 'dateext', 'copytruncate', 'notifempty', 'delaycompress', 'ifempty', 'mailfirst', 'nocompress', 'nocopy', 'nocopytruncate', 'nocreate', 'nodelaycompress', 'nomail', 'nomissingok', 'noolddir', 'nosharedscripts', 'notifempty', 'sharedscripts']
  path = Array(params[:path])
  options_tmp = params[:options] ||= ["missingok", "compress", "delaycompress", "copytruncate", "notifempty"]
  options = options_tmp.respond_to?(:each) ? options_tmp : options_tmp.split

  if params[:enable]

    invalid_options = options - acceptable_options
    unless invalid_options.size.empty?
        Chef::Application.fatal! "The passed value(s) [#{invalid_options.join(',')}] are not valid"
    end

    template "/etc/logrotate.d/#{params[:name]}" do
      source params[:template]
      cookbook params[:cookbook]
      mode 0644
      owner "root"
      group "root"
      backup false
      variables(
        :path => path,
        :create => params[:create],
        :frequency => params[:frequency],
        :size => params[:size],
        :minsize => params[:minsize],
        :rotate => params[:rotate],
        :olddir => params[:olddir],
        :sharedscripts => params[:sharedscripts],
        :postrotate => params[:postrotate],
        :prerotate => params[:prerotate],
        :firstaction => params[:firstaction],
        :lastaction => params[:lastaction],
        :options => options
      )
    end

  else

    execute "rm /etc/logrotate.d/#{params[:name]}" do
      only_if{ FileTest.exists?("/etc/logrotate.d/#{params[:name]}") }
      command "rm /etc/logrotate.d/#{params[:name]}"
    end

  end
end
