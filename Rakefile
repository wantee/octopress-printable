require "bundler/gem_tasks"
require_relative "lib/octopress-printable"

config_yml = 'assets/config.yml'

file config_yml => 'lib/octopress-printable.rb' do
  File.open(config_yml, 'w') {
    |f| f.write(Octopress::Printable::Plugin.default_config) 
  }
end

task :build => config_yml

