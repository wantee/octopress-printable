# octopress-printable

An octopress ink plugin generating printable version of markdown posts.

[![Build Status](https://travis-ci.org/wantee/octopress-printable.svg)](https://travis-ci.org/wantee/octopress-printable)
[![Gem Version](https://badge.fury.io/rb/octopress-printable.svg)](http://badge.fury.io/rb/octopress-printable)
[![License](http://img.shields.io/:license-mit-blue.svg)](https://github.com/wantee/octopress-printable/blob/master/LICENSE.txt)

## Prerequisites
* [Pandoc](pandoc.org/), >= 1.13.2
* TeX Live 2013

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'octopress-printable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install octopress-printable

## Usage

Add `{% include octopress-printable:printable.html %}` to your site's layout, this will create a link to the pdf files corresponding current post or page.

Tags will be converted includes `img` (from [octopress-image-tag](https://github.com/octopress/image-tag)), `gist` (from [octopress-gist](https://github.com/octopress/gist)), `bibliography` and `cite` (from [jekyll-scholar](https://github.com/inukshuk/jekyll-scholar)).

Details please refer to `test/test-site/_posts/2015-04-29-foo.markdown`.

## Configuration

To configure this plugin, run `$ octopress ink copy octopress-printable --config`, then the config should be in `_plugins/octopress-printable/config.yml` and add your settings. Here are
the defaults.

```yaml config
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

```

## Contributing

1. Fork it ( https://github.com/wantee/octopress-printable/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
