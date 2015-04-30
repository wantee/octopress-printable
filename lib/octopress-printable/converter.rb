module Octopress
  module Printable
    class Converter 

      attr_accessor :match

      def initialize()
        @match = false
      end

      def convert(line)
        line
      end
      
      def header()
        []
      end

      def pandoc_args
        []
      end

      def xelatex_args(step)
        []
      end

      def before_xelatex(step, texfile)
        []
      end

      def last_xelatex(texfile)
        []
      end
    end
  end
end

