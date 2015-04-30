module Octopress
  module Printable
    class MathConverter < Converter

      def convert(line)
        str = line.gsub(/\$\$\s*\\begin{equation}/, '\\begin{equation}')
        str.gsub!(/\\end{equation}\s*\$\$/, '\\end{equation}')

        str.gsub!(/\\\*/, '*')
        str.gsub!(/\\\|/, '|')
        str.gsub!(/\\_/, '_')

        if !@match
          if str != line
            @match = true
          end
        end

        str
      end
    end
  end
end

