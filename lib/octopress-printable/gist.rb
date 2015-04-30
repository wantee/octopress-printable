require 'octopress-printable/gist_cache'

module Octopress
  module Printable
    class GistConverter < Converter

      def convert(line)
        str = line

        if /{%\s+gist\s+(?<gist_txt>.*?)\s+%}/ =~ str
          @match = true

          gist = GistCache.new(gist_txt)
          gist_file = gist.render()
          if gist_file == ""
            str = ""
          else
            lang = "text"
            if /\.py$/ =~ gist_file
              lang = 'Python'
            end
 
            str = "\\inputminted[mathescape, linenos, frame=lines, framesep=2mm]{#{lang}}{#{gist_file}}"
          end
        end

        str
      end
    end
  end
end

