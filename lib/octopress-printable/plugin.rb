module Octopress
  module Printable
    autoload :Config,              'octopress-printable/config'
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
          pdf = p.url.sub(/^\//, "")
          pdf = pdf.sub(/\/$/, "")
          pdf = pdf.gsub(/\//, "-")
          pdf = "#{printables_dir}/#{pdf}.pdf"

          if !File.exists?(pdf) || File.stat(post).mtime > File.stat(pdf).mtime
            puts "Converting #{post} to #{pdf}"
            gen_pdf(post, pdf, source_dir, posts_dir, blog_url,
                    bib_dir, bib, p.url)
            if File.exists?(pdf)
              site.static_files << Jekyll::StaticFile.new(site,
                      site.source, printables_dir, File.basename(pdf))
            end
          end
        end
      end
  
      def inject_configs
        @conf = self.config
        @conf = Jekyll::Utils.deep_merge_hashes(YAML.load(Config.default_config), @conf)
      end

      def gen_pdf(mdfile, pdffile, source_dir, posts_dir, blog_url,
              bib_dir, bib_file, post_url)
        pdfdir = File.dirname(pdffile)
        if ! File.exists?(pdfdir)
          FileUtils.mkdir_p pdfdir
        end
      
        converters = []
        math = MathConverter.new
        converters << math
        img = ImgConverter.new(source_dir)
        converters << img
        bib = BibConverter.new("#{source_dir}/#{bib_dir}/#{bib_file}",
                "#{pdfdir}/#{bib_file}")
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

          url = "#{blog_url}/#{post_url}".gsub(/([^:])\/\/+/, '\1/')
          post.puts "\\renewcommand{\\thefootnote}{}\\footnotetext{Online version at \\url{#{url}}}"
        end 
      
        cts = []
        for converter in converters
          if converter.match
            cts << converter
          end
        end
        converters = cts

        texfile = pdffile.sub(/.pdf$/, '.tex')
        base = pdffile.sub(/.pdf$/, '')
        pkgfile = "#{pdffile}.header.tex"

        File.open(pkgfile, "w") { |f|
          for converter in converters
            converter.header.each do |h|
              f.puts h
            end
          end
        }

        cmds = []
        args = []
        for converter in converters
          args += converter.pandoc_args
        end

        cmds << "pandoc -s -N #{args.join(" ")} --include-in-header=#{pkgfile} #{tmpfile} -o #{texfile} " 

        (1..2).each do |step|
          args = []
          extra_cmds = []
          for converter in converters
            extra_cmds += converter.before_xelatex(step, texfile)
          end
          for cmd in extra_cmds
            cmds << cmd
          end

          for converter in converters
            args += converter.xelatex_args(step)
          end
      	  cmds << "xelatex #{args.join(" ")} -output-directory=#{pdfdir} -no-pdf --interaction=nonstopmode #{base} >/dev/null"
        end

        extra_cmds = []
        for converter in converters
          extra_cmds += converter.before_xelatex(3, texfile)
        end
        for cmd in extra_cmds
          cmds << cmd
        end
      	cmds << "xelatex #{args.join(" ")} -output-directory=#{pdfdir} --interaction=nonstopmode #{base} >/dev/null"
      
        extra_cmds = []
        for converter in converters
          extra_cmds += converter.last_xelatex(texfile)
        end
        for cmd in extra_cmds
          cmds << cmd
        end

        if ! @conf['dry_run']
          for cmd in cmds
            system cmd
          end
        end

        if @conf['dump_cmds']
          File.open("#{base}.sh", 'w') { |f|
            f.write(cmds.join("\n"))
          }
          FileUtils.chmod(0755, "#{base}.sh")
        end

        if File.exists?("#{File.basename(base)}.pyg")
          FileUtils.mv("#{File.basename(base)}.pyg", pdfdir)
        end

        if !@conf['keep_tmp_files']
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
          FileUtils.rm_f("#{base}.pyg")
        end
      
        if !@conf['dump_tex_file']
          FileUtils.rm_f("#{texfile}")
          FileUtils.rm_f("#{pkgfile}")
        end

        if !@conf['dump_markdown_file']
          FileUtils.rm_f("#{tmpfile}")
        end

        if !@conf['dump_bib_file'] && bib.match
          bib.cleanup
        end
      end
      
    end
  end
end
