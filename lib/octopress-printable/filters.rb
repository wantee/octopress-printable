module Octopress
  module Printable
    module Filters
      def url2filename(url)
        url = url.to_s.gsub(/\//, '-')
        url = url.sub(/^[^0-9]*-/, '')
        url = url.sub(/-$/, '')
      end
    end
  end
end

