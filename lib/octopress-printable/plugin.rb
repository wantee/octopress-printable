module Octopress
  module Printable
    autoload :Converter,           'octopress-printable/converter'
    autoload :MathConverter,       'octopress-printable/math'
    autoload :ImgConverter,        'octopress-printable/img'
    autoload :BibConverter,        'octopress-printable/bib'
    autoload :GistConverter,       'octopress-printable/gist'
    autoload :PostLinkConverter,   'octopress-printable/post_link'

    class Plugin < Ink::Plugin

      def register
        super
        if Octopress::Ink.enabled?
          self.generate(Octopress.site, config)
        end
      end

      def generate(site, config)
        conf = inject_configs

        posts_dir = conf['posts_dir']
        printables_dir = conf['printables_dir']
        source_dir = conf['source_dir']
        blog_url = conf['blog_url']
        bib_dir = conf['bibliography_dir']
        bib = conf['bibliography']

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
        conf = self.config
        conf = Jekyll::Utils.deep_merge_hashes(YAML.load(Plugin.default_config), conf)
      end

      def self.default_config
<<-CONFIG
posts_dir:           "_posts"
printables_dir:      "assets/printables"
source_dir:          "."
blog_url:            "http://example.com"
bibliography_dir:    "_bibliography"
bibliography:        "references.bib"

CONFIG
      end

      def post_url(user, project, source_dir)
        cname = "#{source_dir}/CNAME"
        url = if File.exists?(cname)
          "http://#{IO.read(cname).strip}"
        else
          "http://#{user.downcase}.github.io"
        end
        url += "/#{project}" unless project == ''
        url
      end
      
      def gen_pdf(mdfile, pdffile, source_dir, posts_dir, blog_url, bib_dir, bib)
        pdfdir = File.dirname(pdffile)
        if ! File.exists?(pdfdir)
          FileUtils.mkdir_p pdfdir
        end
      
        converters = []
        math = MathConverter.new
        converters << math
#        img = ImgConverter.new
#        converters << img
        bib = BibConverter.new("#{source_dir}/#{bib_dir}/#{bib}",
                "#{pdfdir}/#{bib}")
        converters << bib
        gist = GistConverter.new
        converters << gist
        post_link = PostLinkConverter.new(source_dir, posts_dir, blog_url)
        converters << post_link

#        has_bib = false
#        has_gist = false
      
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
      
              line = line.gsub(/\* list element with functor item/, '')
              line = line.gsub(/{:toc}/, '\tableofcontents')
      
              line = line.sub(/^#(#*)/, '\1')
      
              for converter in converters
                line = converter.convert(line)
              end

#              if /{% img (?<markup>.*) %}/ =~ line
#                @img = get_img_label(markup)
#                line="\\begin{figure}[h]\\centering\\includegraphics[width=\\textwidth]{#{source_dir}/#{@img['src']}}\\caption{#{@img['title']}}\\label{#{@img['alt']}}\\end{figure}"
#              end
#      
#              while /{% comment %} FOR-LATEX (?<markup>.*) {% endcomment %}/ =~ line
#                line = line.sub(/{% comment %} FOR-LATEX (.*?) {% endcomment %}/, markup)
#              end
#      
#              line = line.gsub(/{% comment %} (.*?) {% endcomment %}/, "")
#      
      
              post.puts line
            end  
          end
        end 
      
#        texfile=pdffile.sub(/.pdf$/, '.tex')
#        base=pdffile.sub(/.pdf$/, '')
#        pkgfile="#{pdfdir}/header.tex"
#        system "echo > #{pkgfile}"
#        if has_gist
#          system "echo \"\\usepackage{minted}\" >> #{pkgfile}"
#        end
#      
#        if has_bib
#          system "echo \"\\usepackage[sort&compress, numbers]{natbib}\" >> #{pkgfile}"
#      
#          system "pandoc -s --include-in-header=#{pkgfile} #{tmpfile} -o #{texfile} "
#      	system "xelatex -output-directory=#{pdfdir} -no-pdf --interaction=nonstopmode #{base} >/dev/null"
#      	system "bibtex #{base} >/dev/null"
#      	system "xelatex -output-directory=#{pdfdir} -no-pdf --interaction=nonstopmode #{base} >/dev/null"
#      	system "xelatex -output-directory=#{pdfdir} --interaction=nonstopmode #{base} >/dev/null"
#      
#          system "rm -rf #{bib}"
#      	system "rm -rf #{pdfdir}/*.aux"
#      	system "rm -rf #{pdfdir}/*.log"
#      	system "rm -rf #{pdfdir}/*.lot"
#      	system "rm -rf #{pdfdir}/*.out"
#      	system "rm -rf #{pdfdir}/*.toc"
#      	system "rm -rf #{pdfdir}/*.blg"
#      	system "rm -rf #{pdfdir}/*.bbl"
#      	system "rm -rf #{pdfdir}/*.lof"
#      	system "rm -rf #{pdfdir}/*.xdv"
#      	system "rm -rf #{pdfdir}/*.hst"
#      	system "rm -rf #{pdfdir}/*.ver"
#      	system "rm -rf #{pdfdir}/*.synctex.gz"
#        else
#          system "pandoc --include-in-header=#{pkgfile} --latex-engine=xelatex -N #{tmpfile} -o #{pdffile}"
#        end
#      
#        system "rm -rf #{pkgfile}"
#        system "rm -rf #{tmpfile}"
#        system "rm -rf input.pyg"
      end
      
      # from image_tag plugin
      def get_img_label(markup)
        @img = nil
        attributes = ['class', 'src', 'width', 'height', 'title']
      
        if markup =~ /(?<class>\S.*\s+)?(?<src>(?:https?:\/\/|\/|\S+\/)\S+)(?:\s+(?<width>\d+))?(?:\s+(?<height>\d+))?(?<title>\s+.+)?/i
          @img = attributes.reduce({}) { |img, attr| img[attr] = $~[attr].strip if $~[attr]; img }
          if /(?:"|')(?<title>[^"']+)?(?:"|')\s+(?:"|')(?<alt>[^"']+)?(?:"|')/ =~ @img['title']
            @img['title']  = title
            @img['alt']    = alt
          else
      #@img['alt']    = @img['title'].gsub!(/"/, '&#34;') if @img['title']
            @img['alt']    = @img['title']
          end
          @img['class'].gsub!(/"/, '') if @img['class']
        end
        @img
      end
      
    end
  end
end
