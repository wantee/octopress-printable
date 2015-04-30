require 'octopress-printable/version'
require 'octopress-ink'

module Octopress
  module Printable
    autoload :Filters,         'octopress-printable/filters'
    autoload :Tags,            'octopress-printable/tags'
    autoload :Plugin,          'octopress-printable/plugin'
  end
end

Liquid::Template.register_filter(Octopress::Printable::Filters)

Liquid::Template.register_tag('post_link', Octopress::Printable::Tags)

Octopress::Ink.register_plugin(Octopress::Printable::Plugin, { 
  name:          "Octopress Printable",
  slug:          "octopress-printable",
  gem:           "octopress-printable",
  path:          File.expand_path(File.join(File.dirname(__FILE__), "..")),
  type:          "plugin",
  version:       Octopress::Printable::VERSION,
  description:   "Printable version for post generator.",
  source_url:    "https://github.com/wantee/octopress-printable",
  website:       "" 
})
