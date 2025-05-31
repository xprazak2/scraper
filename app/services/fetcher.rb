class Fetcher
  def fetch(url)
    # we might want to consider additional validation for url before making the actual request
    begin
      res = HTTPX.get(url)
    rescue HTTPX::Error => e
      raise FetchError, e.message
    end

    if res.status != 200
      raise FetchError, "could not fetch data, target server responded with #{res.status}"
    end

    res.to_s
  end
end
