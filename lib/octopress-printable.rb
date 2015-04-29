require 'octopress-printable/version'
require 'octopress-ink'

Octopress::Ink.add_plugin({
  name:          "Octopress Printable",
  slug:          "octopress-printable",
  gem:           "octopress-printable",
  path:          File.expand_path(File.join(File.dirname(__FILE__), "..")),
  type:          "plugin",
  version:       OctopressPrintable::VERSION,
  description:   "Printable version for post generator.",
  source_url:    "https://github.com/wantee/octopress-printable",
  website:       "" 
})
