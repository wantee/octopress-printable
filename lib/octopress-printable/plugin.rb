module Octopress
  module Printable
    autoload :Converter,           'octopress-printable/converter'
    autoload :MathConverter,       'octopress-printable/math'
    autoload :ImgConverter,        'octopress-printable/img'
    autoload :BibConverter,        'octopress-printable/bib'
    autoload :GistConverter,       'octopress-printable/gist'
    autoload :PostLinkConverter,   'octopress-printable/post_link'
    autoload :LatexConverter,      'octopress-printable/latex'

    class Plugin < Ink::Plugin

      def register
        super
        if Octopress::Ink.enabled?
          self.generate(Octopress.site, config)
        end
      end

      def generate(site, config)
        @conf = inject_configs

        posts_dir = @conf['posts_dir']
        printables_dir = @conf['printables_dir']
        source_dir = @conf['source_dir']
        blog_url = @conf['blog_url']
        bib_dir = @conf['bibliography_dir']
        bib = @conf['bibliography']

        if !File.exists?(printables_dir)
          FileUtils.mkdir_p(printables_dir)
        end

        site.posts.each do |p|
          post = p.path
          pdf = post.sub(/#{posts_dir}\//, "#{printables_dir}/")
          pdf = pdf.sub(/\.markdown$/, ".pdf")
          pdf = pdf.sub(/\.md$/, ".pdf")

          if !File.exists?(pdf) || File.stat(post).mtime > File.stat(pdf).mtime
            puts "Converting #{post} to #{pdf}"
            gen_pdf(post, pdf, source_dir, posts_dir, blog_url, bib_dir, bib)
          end
        end
      end
  
      def inject_configs
        @conf = self.config
        @conf = Jekyll::Utils.deep_merge_hashes(YAML.load(Plugin.default_config), @conf)
      end

      def self.default_config
<<-CONFIG
posts_dir:           "_posts"
printables_dir:      "assets/printables"
source_dir:          "."
blog_url:            "http://example.com"
bibliography_dir:    "_bibliography"
bibliography:        "references.bib"

dump_tex_file:       false
dump_markdown_file:  false
dump_bib_file:       false

CONFIG
      end

      def gen_pdf(mdfile, pdffile, source_dir, posts_dir, blog_url, bib_dir, bib)
        pdfdir = File.dirname(pdffile)
        if ! File.exists?(pdfdir)
          FileUtils.mkdir_p pdfdir
        end
      
        converters = []
        math = MathConverter.new
        converters << math
        img = ImgConverter.new(source_dir)
        converters << img
        bib = BibConverter.new("#{source_dir}/#{bib_dir}/#{bib}",
                "#{pdfdir}/#{bib}")
        converters << bib
        gist = GistConverter.new
        converters << gist
        post_link = PostLinkConverter.new(source_dir, posts_dir, blog_url)
        converters << post_link
        latex = LatexConverter.new
        converters << latex

        tmpfile="#{pdffile}.markdown"
        comment = false
        File.open(tmpfile, 'w') do |post|
          File.open(mdfile, "r") do |file|  
            while line = file.gets
              line = line.strip
      
              if /^{% comment %}$/ =~ line
                comment = true
                next
              end
      
              if /^{% endcomment %}$/ =~ line
                comment = false
                next
              end
      
              if comment
                next
              end
      
              line = line.gsub(/{% comment %} (.*?) {% endcomment %}/, "")

              line = line.gsub(/\* list element with functor item/, '')
              line = line.gsub(/{:toc}/, '\tableofcontents')
      
              line = line.sub(/^#(#*)/, '\1')
      
              for converter in converters
                line = converter.convert(line)
              end

              post.puts line
            end  
          end
        end 
      
        texfile = pdffile.sub(/.pdf$/, '.tex')
        base = pdffile.sub(/.pdf$/, '')
        pkgfile = "#{pdffile}.header.tex"

        File.open(pkgfile, "w") { |f|
          if img.match
            f.puts '\\usepackage{graphicx}'
            f.puts '\\usepackage[all]{hypcap}'
          end

          if gist.match
            f.puts '\\usepackage{minted}'
          end
      
          if bib.match
            f.puts '\\usepackage[sort&compress, numbers]{natbib}'
          end
        }

        system "pandoc -s -N --include-in-header=#{pkgfile} #{tmpfile} -o #{texfile} "
      	system "xelatex -output-directory=#{pdfdir} -no-pdf --interaction=nonstopmode #{base} >/dev/null"
        if bib.match
      	  system "bibtex #{base} >/dev/null"
        end
      	system "xelatex -output-directory=#{pdfdir} -no-pdf --interaction=nonstopmode #{base} >/dev/null"
      	system "xelatex -output-directory=#{pdfdir} --interaction=nonstopmode #{base} >/dev/null"
      
      	FileUtils.rm_f("#{base}.aux")
      	FileUtils.rm_f("#{base}.log")
      	FileUtils.rm_f("#{base}.lot")
      	FileUtils.rm_f("#{base}.out")
      	FileUtils.rm_f("#{base}.toc")
      	FileUtils.rm_f("#{base}.blg")
      	FileUtils.rm_f("#{base}.bbl")
      	FileUtils.rm_f("#{base}.lof")
      	FileUtils.rm_f("#{base}.xdv")
      	FileUtils.rm_f("#{base}.hst")
      	FileUtils.rm_f("#{base}.ver")
      	FileUtils.rm_f("#{base}.synctex.gz")
        FileUtils.rm_f("#{File.basename(base)}.pyg")
      
        if !@conf['dump_tex_file']
          FileUtils.rm_f("#{texfile}")
          FileUtils.rm_f("#{pkgfile}")
        end
        if !@conf['dump_markdown_file']
          FileUtils.rm_f("#{tmpfile}")
        end
        if !@conf['dump_bib_file']
          bib.cleanup
        end
      end
      
    end
  end
end
