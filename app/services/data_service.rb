class DataService
  def initialize(fetcher, parser, cacher)
    @fetcher = fetcher
    @parser = parser
    @cacher = cacher
  end

  def process(url, fields)
    cached_item = @cacher.get(url)

    item, missing_fields = diff cached_item, fields
    return item if missing_fields.empty?

    raw_doc = @fetcher.fetch url
    res = @parser.parse raw_doc, missing_fields

    @cacher.set(url, merge_full(cached_item, res))

    merge_full item, res
  end

  def diff(item, fields)
    return [ {}, fields ] if item.nil?
    # maybe item should be custom object instance with `diff` method for better ergonomics
    to_remove = item.keys - fields.keys
    to_add = fields.keys - item.keys

    filtered_item = item.except(*to_remove)
    filtered_fields = fields.except(*filtered_item.keys)

    if item.keys.intersection(fields.keys).include?("meta")
      meta_remove = item["meta"].keys - fields["meta"]
      meta_add = fields["meta"] - item["meta"].keys

      filtered_item["meta"] = filtered_item["meta"].except(*meta_remove)
      filtered_fields["meta"] = meta_add unless meta_add.empty?
    end

    [ filtered_item, filtered_fields ]
  end

  private

  def merge_full(cached_item, additional)
    (cached_item || {}).merge(additional) do |key, old_val, new_val|
      if key == "meta"
        old_val.merge(new_val)
      else
        new_val
      end
    end
  end
end
