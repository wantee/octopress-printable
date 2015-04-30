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
        ""
      end
    end
  end
end

