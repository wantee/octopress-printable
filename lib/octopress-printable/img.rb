module Octopress
  module Printable
    class ImgConverter < Converter

      TITLE_REGEX = /title:['|"](.+?)['|"]/

      def initialize(source_dir)
        super()

        @source_dir = source_dir
      end

      def convert(line)
        str = line

        if /{% img (?<markup>.*) %}/ =~ str
          @match = true

          img = get_img_label(markup)
          str="\\begin{figure}[h]\\centering\\includegraphics[width=\\textwidth]{#{@source_dir}/#{img['src']}}\\caption{#{img['title']}}\\label{#{img['alt']}}\\end{figure}"
        end
 
        str
      end

      # from octopress-image-tag plugin
      def get_img_label(markup)
        title = markup.scan(TITLE_REGEX).flatten.compact.last
        markup.gsub!(TITLE_REGEX, '')

        if markup =~ /(?<class>\S.*\s+)?(?<src>(?:https?:\/\/|\/|\S+\/)\S+)(?:\s+(?<width>\d\S+))?(?:\s+(?<height>\d\S+))?(?<alt>\s+.+)?/i
          attributes = ['class', 'src', 'width', 'height', 'alt']
          image = attributes.reduce({}) { |img, attr| img[attr] ||= $~[attr].strip if $~[attr]; img }
          text = image['alt']

          # Allow parsing "title" "alt"
          if text =~ /(?:"|')(?<title>[^"']+)?(?:"|')\s+(?:"|')(?<alt>[^"']+)?(?:"|')/
            image['title']  = title
            image['alt']    = alt
          else
            # Set alt text and title from text
            image['alt'].gsub!(/"/, '') if image['alt']
          end
        end

        image['title'] ||= title
        image['alt'] ||= title

        image
      end

      def header
        lines = []
        lines << '\\usepackage{graphicx}'
        lines << '\\usepackage[all]{hypcap}'
      end
    end
  end
end

