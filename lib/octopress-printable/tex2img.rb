require 'octopress-printable/img'

module Octopress
  module Printable
    class Tex2imgConverter < Converter

      TITLE_REGEX = /title:['|"](.+?)['|"]/

      def initialize(source_dir)
        super()

        @source_dir = source_dir
        @headers = []
      end

      def convert(line)
        str = line

        if /{% tex2img (?<markup>.*) %}/ =~ str
          @match = true

          @texpath, *params = markup.strip.split(/\s/)
          @texpath = File.join(@source_dir, @texpath)
          if !File.exists?(@texpath)
            raise ArgumentError.new("texfile[#{@texpath}] does not exist!")
          end

          img = Octopress::Printable::ImgConverter.get_img_label(params.join(" "))
          str="\\begin{figure}[h]\\centering\\input{#{@texpath}}\\caption{#{img['title']}}\\label{#{img['alt']}}\\end{figure}"

          @headers += open(@texpath) { |f| f.grep(/\\usepackage/) }
        end
 
        str
      end

      def header
        @headers << '\\usepackage{standalone}'
        @headers << '\\usepackage{tikz}'
        @headers.each {|a| a.strip!if a.respond_to? :strip! }
        @headers.uniq!
      end
    end
  end
end

