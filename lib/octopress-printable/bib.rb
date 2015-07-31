module Octopress
  module Printable
    class BibConverter < Converter

      def initialize(src_bib, tgt_bib)
        super()

        @src_bib = src_bib
        @tgt_bib = tgt_bib
      end

      def convert(line)
        str = line
        if /##*\s*References/ =~ str
          return ""
        end
      
        if /{% bibliography .*? %}/ =~ str
          @match = true

          str = "\\bibliographystyle{unsrt}\\bibliography{#{@tgt_bib.sub(/\..*$/, "")}}"
      
          gen_bib("#{@src_bib}", "#{@tgt_bib}")
        end
      
        while /{% cite\s+(?<citation>.*?)\s+%}/ =~ str
          @match = true
          citation = citation.sub(/\s+/, ',')
          str = str.sub(/{% cite\s+(.*?)\s+%}/, "\\cite{#{citation}}")
        end

        str
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

      def cleanup()
        FileUtils.rm_f(@tgt_bib)
      end

      def header
        lines = []
        lines << '\\usepackage[sort&compress, numbers]{natbib}'
      end

      def before_xelatex(step, texfile)
        cmds = []
        if step == 2
      	  cmds << "bibtex #{texfile.sub(/\.tex$/, "")} >/dev/null"
        end
        cmds
      end
      
    end
  end
end

