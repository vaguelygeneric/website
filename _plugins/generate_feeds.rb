module Jekyll
  module RSSFilters
    def strip_classes(input)
      input.to_s.gsub(/\s+class="[^"]*"/, '')
    end
  end
end

Liquid::Template.register_filter(Jekyll::RSSFilters)

class FeedPage < Jekyll::Page
  def initialize(site, show)
    @site = site
    @base = site.source
    @dir  = "feed"
    @name = "#{show.data['slug']}.xml"

    self.process(@name)
    self.read_yaml(File.join(@base, "_layouts"), "feed.html")

    self.data["show"] = show.data["slug"]
    self.data["layout"] = "feed"
    self.data["permalink"] = "/feed/#{show.data['slug']}.xml"
  end
end

class FeedGenerator < Jekyll::Generator
  safe true

  def generate(site)
    site.collections["shows"].docs.each do |show|
      site.pages << FeedPage.new(site, show)
    end
  end
end