require 'octopress-printable/version'
require 'octopress-ink'

module Octopress
  module Printable
    autoload :Filters,         'octopress-printable/filters'
    autoload :Converter,       'octopress-printable/converter'
    autoload :MathConverter,   'octopress-printable/math'

    class PrintableGenerator < Jekyll::Generator
      safe true
      priority :low
  
      def generate(site)
        posts_dir       = "_posts"
        printables_dir  = "assets/printables"
        source_dir      = "."
        blog_url        = "http://wantee.github.io"

        if site.config['printables_dir'] 
          printables_dir = site.config['printables_dir']
        end

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
            gen_pdf(post, pdf, source_dir, posts_dir, blog_url)
          end
        end
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
      
      def gen_pdf(markdownfile, pdffile, source_dir, posts_dir, blog_url)
        pdfdir = File.dirname(pdffile)
        if ! File.exists?(pdfdir)
          FileUtils.mkdir_p pdfdir
        end
      
        converters = []
        math = MathConverter.new
        converters << math

        obib="#{source_dir}/_bibliography/references"
        bib="#{pdfdir}/references"
        has_bib = false
        has_gist = false
      
        tmpfile="#{pdffile}.markdown"
        comment = false
        File.open(tmpfile, 'w') do |post|
          File.open(markdownfile, "r") do |file|  
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

              if /{% img (?<markup>.*) %}/ =~ line
                @img = get_img_label(markup)
                line="\\begin{figure}[h]\\centering\\includegraphics[width=\\textwidth]{#{source_dir}/#{@img['src']}}\\caption{#{@img['title']}}\\label{#{@img['alt']}}\\end{figure}"
              end
      
              while /{% comment %} FOR-LATEX (?<markup>.*) {% endcomment %}/ =~ line
                line = line.sub(/{% comment %} FOR-LATEX (.*?) {% endcomment %}/, markup)
              end
      
              line = line.gsub(/{% comment %} (.*?) {% endcomment %}/, "")
      
              while /{% post_link (?<markup>[^\s]+)(?<text>\s+.+)? %}/ =~ line
                /^(?<year>\d+)-(?<month>\d+)-(?<day>\d+)-(?<title>.*)/ =~ markup
      
                if ! text
                  File.open("#{source_dir}/#{posts_dir}/#{markup}.markdown", 'r') do |f|
                      while l = f.gets
                        if /title: (?:"|')(?<text>.*)(?:"|')/ =~ l
                          break
                        end
                      end
                  end
                end
                line = line.sub(/{% post_link (.*?) %}/, "\\href{#{blog_url}/blog/#{year}/#{month}/#{day}/#{title}/}{#{text}}")
              end
      
              if /##*\s*References/ =~ line
                next
              end
      
              if /{% bibliography .*? %}/ =~ line
                line="\\bibliographystyle{unsrt}\\bibliography{#{bib}}"
                has_bib=true
      
                gen_bib("#{obib}.bib", "#{bib}.bib")
              end
      
              while /{% cite\s+(?<citation>.*?)\s+%}/ =~ line
                citation=citation.sub(/\s+/, ',')
                line=line.sub(/{% cite\s+(.*?)\s+%}/, "\\cite{#{citation}}")
              end
      
#              if /{%\s+gist\s+(?<gist_txt>.*?)\s+%}/ =~ line
#                has_gist=true
#                gist = Gist.new(gist_txt)
#                gist_file = gist.render()
#                if gist_file == ""
#                  line = ""
#                else
#                  lang = "text"
#                  if /\.py$/ =~ gist_file
#                    lang = 'Python'
#                  end
#      
#                  line = "\\inputminted[mathescape, linenos, frame=lines, framesep=2mm]{#{lang}}{#{gist_file}}"
#                end
#              end
      
              post.puts line
            end  
          end
        end 
      
        texfile=pdffile.sub(/.pdf$/, '.tex')
        base=pdffile.sub(/.pdf$/, '')
        pkgfile="#{pdfdir}/header.tex"
        system "echo > #{pkgfile}"
        if has_gist
          system "echo \"\\usepackage{minted}\" >> #{pkgfile}"
        end
      
        if has_bib
          system "echo \"\\usepackage[sort&compress, numbers]{natbib}\" >> #{pkgfile}"
      
          system "pandoc -s --include-in-header=#{pkgfile} #{tmpfile} -o #{texfile} "
      	system "xelatex -output-directory=#{pdfdir} -no-pdf --interaction=nonstopmode #{base} >/dev/null"
      	system "bibtex #{base} >/dev/null"
      	system "xelatex -output-directory=#{pdfdir} -no-pdf --interaction=nonstopmode #{base} >/dev/null"
      	system "xelatex -output-directory=#{pdfdir} --interaction=nonstopmode #{base} >/dev/null"
      
          system "rm -rf #{bib}"
      	system "rm -rf #{pdfdir}/*.aux"
      	system "rm -rf #{pdfdir}/*.log"
      	system "rm -rf #{pdfdir}/*.lot"
      	system "rm -rf #{pdfdir}/*.out"
      	system "rm -rf #{pdfdir}/*.toc"
      	system "rm -rf #{pdfdir}/*.blg"
      	system "rm -rf #{pdfdir}/*.bbl"
      	system "rm -rf #{pdfdir}/*.lof"
      	system "rm -rf #{pdfdir}/*.xdv"
      	system "rm -rf #{pdfdir}/*.hst"
      	system "rm -rf #{pdfdir}/*.ver"
      	system "rm -rf #{pdfdir}/*.synctex.gz"
        else
          system "pandoc --include-in-header=#{pkgfile} --latex-engine=xelatex -N #{tmpfile} -o #{pdffile}"
        end
      
        system "rm -rf #{pkgfile}"
        system "rm -rf #{tmpfile}"
        system "rm -rf input.pyg"
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
      
      def gen_bib(obib, bib)
        File.open(obib, 'r') do |f|
          File.open(bib, 'w') do |o|
            while l = f.gets
              if /<a\s+href="?(?<url>.*?)"?\s*>(?<text>.*?)<\/a>/ =~ l
                l = l.sub(/<a\s+href=(.*?)>(.*?)<\/a>/, "\\href{#{url}}{#{text}}")
              end
      
              o.puts l
            end
          end
        end
      end

    end
  end
end

Liquid::Template.register_filter(Octopress::Printable::Filters)

Octopress::Ink.add_plugin({
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
