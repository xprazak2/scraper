class Cacher
  def get(url)
    Rails.cache.fetch(url)
  end

  def set(url, data)
    Rails.cache.write(url, data)
  end
end
