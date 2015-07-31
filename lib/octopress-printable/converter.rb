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

      def envs()
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

      def self.get_includes(post, source_dir)
        []
      end

      # return the newest timestamp for included files
      def self.timestamp(post, source_dir)
        includes = get_includes(post, source_dir)
        ts = Time.new(0)
        includes.each { |f|
          if File.exists?(f) && File.stat(f).mtime > ts
            ts = File.stat(f).mtime
          end
        }
        ts
      end
    end
  end
end

