module Jekyll
  module InstallmentFilters
    # Filters a collection down to items that should be publicly *listed*
    # -- on a strand page, in a feed, on the homepage, or on a guest
    # profile. Pass a field/value to match a specific strand (e.g. only
    # "daily" episodes), or omit both to gate a collection as a whole
    # (e.g. the homepage's cross-show episode list).
    #
    #   site.podcast | listed_installments: "show", page.slug
    #   site.podcast | listed_installments: "guests", page.slug   (array fields work too)
    #   site.podcast | listed_installments
    #
    # Note this only controls whether an item is *linked to* from a
    # listing -- it never removes anything from the underlying
    # collection, so every installment's own page still builds and is
    # reachable by direct URL regardless of status or date.
    #
    #   status: draft      -> never listed, regardless of date
    #   status: published  -> always listed, regardless of date
    #   status: scheduled, or unset -> listed once publish_date
    #                          (falling back to created) has passed
    def listed_installments(items, field = nil, value = nil)
      now = @context.registers[:site].time

      items.select do |item|
        if field
          match = item.data[field]
          next false unless match == value || (match.is_a?(Array) && match.include?(value))
        end

        status = item.data["status"]
        next false if status == "draft"
        next true if status == "published"

        publish_date = item.data["publish_date"] || item.data["created"]
        next true if publish_date.nil?
        publish_date.to_time <= now
      end
    end

    # Same idea, one level up -- hides a whole strand (show/comic/story)
    # from nav, landing pages, and hero pills while it's `status: draft` or `status: hidden`.
    def listed_strands(items)
      items.reject { |item| item.data["status"] == "draft" || item.data["status"] == "hidden" }
    end
  end
end

Liquid::Template.register_filter(Jekyll::InstallmentFilters)
