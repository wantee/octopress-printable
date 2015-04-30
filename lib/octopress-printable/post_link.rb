module Octopress
  module Printable
    class PostLinkConverter < Converter

      def initialize(source_dir, posts_dir, blog_url)
        super()

        @source_dir = source_dir
        @posts_dir = posts_dir
        @blog_url = blog_url
      end

      def convert(line)
        str = line

        while /{% post_link (?<markup>[^\s]+)(?<text>\s+.+)? %}/ =~ str
          /^(?<year>\d+)-(?<month>\d+)-(?<day>\d+)-(?<title>.*)/ =~ markup

          if ! text
            File.open("#{@source_dir}/#{@posts_dir}/#{markup}.markdown", 'r') do |f|
                while l = f.gets
                  if /title: (?:"|')(?<text>.*)(?:"|')/ =~ l
                    break
                  end
                end
            end
          end
          str = str.sub(/{% post_link (.*?) %}/, "\\href{#{@blog_url}/#{year}/#{month}/#{day}/#{title}/}{#{text}}")
        end

        str
      end
    end
  end
end

