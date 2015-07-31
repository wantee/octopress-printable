require 'octopress-printable/img'

module Octopress
  module Printable
    class Tex2imgConverter < Converter

      TITLE_REGEX = /title:['|"](.+?)['|"]/

      def initialize(source_dir)
        super()

        @source_dir = source_dir
        @headers = []
        @inputs = []
      end

      def convert(line)
        str = line

        if /{% tex2img (?<markup>.*) %}/ =~ str
          @match = true

          texpath, *params = markup.strip.split(/\s/)
          texpath = File.join(@source_dir, texpath)
          if !File.exists?(texpath)
            raise ArgumentError.new("texfile[#{texpath}] does not exist!")
          end

          img = Octopress::Printable::ImgConverter.get_img_label(params.join(" "))
          str="\\begin{figure}[h]\\centering\\input{#{texpath}}\\caption{#{img['title']}}\\label{#{img['alt']}}\\end{figure}"

          @headers += open(texpath) { |f| f.grep(/\\usepackage/) }

          add_envs(texpath)
        end
        str
      end

      def header
        @headers << '\\usepackage{standalone}'
        @headers << '\\usepackage{tikz}'
        @headers.each {|a| a.strip!if a.respond_to? :strip! }
        @headers.uniq!
      end

      def add_envs(texpath)
        File.open(texpath, 'r') do |ff|
          while ll = ff.gets
            if /\\input{(?<inputfile>.*)}/ =~ ll
               @inputs << File.dirname(texpath)
            end
          end
        end
      end

      def envs
        ["export TEXINPUTS+='#{@inputs.join(':')}:'"]
      end

      def self.get_includes(post, source_dir)
        includes = []
        File.open(post, 'r') do |f|
          while l = f.gets
            if /{% tex2img (?<markup>.*) %}/ =~ l
              texpath, *params = markup.strip.split(/\s/)
              texpath = File.join(source_dir, texpath)
              if !File.exists?(texpath)
                next
              end
              includes << texpath

              File.open(texpath, 'r') do |ff|
                while ll = ff.gets
                  if /\\input{(?<inputfile>.*)}/ =~ ll
                    includes << File.join(File.dirname(texpath), inputfile)
                  end
                end
              end
            end
          end
        end
        includes
      end
    end
  end
end

