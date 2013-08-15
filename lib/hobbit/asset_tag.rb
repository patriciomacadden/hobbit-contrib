module Hobbit
  module AssetTag
    def image_path(url)
      url =~ /^https?:\/\// ? url : "/images/#{url}"
    end

    def javascript(*urls)
      urls.map { |url| "<script src=\"#{javascript_path url}\" type=\"text/javascript\"></script>" }.join
    end

    def javascript_path(url)
      url =~ /^https?:\/\// ? url : "/javascripts/#{url}.js"
    end

    def stylesheet(*urls)
      urls.map { |url| "<link href=\"#{stylesheet_path url}\" rel=\"stylesheet\"/>" }.join
    end

    def stylesheet_path(url)
      url =~ /^http(s)?:\/\// ? url : "/stylesheets/#{url}.css"
    end
  end
end
