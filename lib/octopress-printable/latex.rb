module Octopress
  module Printable
    class LatexConverter < Converter

      def convert(line)
        str = line
        while /{{\s+(?<arg>\S+)\s*\|\s*latex:(?<cmd>\S+)\s*\s*}}/ =~ str
          @match = true
          if ! arg.gsub!(/\A"|"\Z/, '')
            arg.gsub!(/\A'|'\Z/, '')
          end

          str.sub!(/{{\s+\S+\s*\|\s*latex:\S+\s*}}/, "(\\#{cmd}{#{arg}})")
        end

        str
      end
    end
  end
end

