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
          @match = true

          found_year = false
          if /^(?<year>\d+)-(?<month>\d+)-(?<day>\d+)-(?<title>.*)/ =~ markup
            found_year = true
          end

          if ! text
            File.open("#{@source_dir}/#{@posts_dir}/#{markup}.markdown", 'r') do |f|
                found_text = false
                while l = f.gets
                  if /title: (?:"|')(?<text>.*)(?:"|')/ =~ l
                    found_text = true
                  end
                  if ! found_year
                    if /date: (?<year>\d+)-(?<month>\d+)-(?<day>\d+)/ =~ l
                      found_year = true
                    end
                  end
                    
                  if found_text && found_year
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

