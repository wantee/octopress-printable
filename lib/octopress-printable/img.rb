module Octopress
  module Printable
    class BibConverter < Converter

      def initialize(src_bib, tgt_bib)
        super()

        @src_bib=src_bib
        @tgt_bib=tgt_bib
      end

      def convert(line)
        if /##*\s*References/ =~ line
          ""
        end
      
        if /{% bibliography .*? %}/ =~ line
          @match = true

          str = "\\bibliographystyle{unsrt}\\bibliography{#{File.basename(@tgt_bib, ".*")}}"
      
          gen_bib("#{@src_bib}", "#{@tgt_bib}")
        end
      
        while /{% cite\s+(?<citation>.*?)\s+%}/ =~ line
          @match = true
          citation = citation.sub(/\s+/, ',')
          str = line.sub(/{% cite\s+(.*?)\s+%}/, "\\cite{#{citation}}")
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

    end
  end
end

