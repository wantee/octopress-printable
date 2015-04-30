module Octopress
  module Printable
    class MathConverter < Converter

      def convert(line)
        @match = !!line.gsub!(/\$\$\s*\\begin{equation}/, '\\begin{equation}')
        @match = !!line.gsub!(/\\end{equation}\s*\$\$/, '\\end{equation}')

        @match = !!line.gsub!(/\\\*/, '*')
        @match = !!line.gsub!(/\\\|/, '|')
        @match = !!line.gsub!(/\\_/, '_')

        line
      end
    end
  end
end

