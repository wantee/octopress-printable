require "bundler/gem_tasks"
require_relative "lib/octopress-printable"

config_yml = 'assets/config.yml'
readme = 'README.md'

file config_yml => 'lib/octopress-printable/plugin.rb' do
  File.open(config_yml, 'w') { |f|
    f.write(Octopress::Printable::Plugin.default_config) 
  }
end

file readme => config_yml do
  tmp = "#{readme}.tmp"
  File.open(tmp, 'w') { |f|
    inyaml = false
    File.open(readme, 'r').each { |line|
      
      if /```yaml config/ =~ line
        inyaml = true
        f.write(line)
        f.write(Octopress::Printable::Plugin.default_config) 
        next
      end
      if inyaml && /```/ =~ line
        inyaml = false
      end
      
      if ! inyaml
        f.write(line)
      end
    }
  }
  FileUtils.mv(tmp, readme)
end

task :build => [config_yml, readme]

