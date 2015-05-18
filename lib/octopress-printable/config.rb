module Octopress
  module Printable
    class Config 

      def self.default_config
<<-CONFIG
posts_dir:           "_posts"
printables_dir:      "assets/printables"
source_dir:          "."
blog_url:            "http://example.com"  # used in pdf post_links
bibliography_dir:    "_bibliography"
bibliography:        "references.bib"

# only convert markdowns, without running pandoc and xelatex
dry_run      :       false

# debug files
dump_tex_file:       false
dump_markdown_file:  false
dump_bib_file:       false
dump_cmds:           false
keep_tmp_files:      false

CONFIG
      end

    end
  end
end
