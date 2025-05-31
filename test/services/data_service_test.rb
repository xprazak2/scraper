require "test_helper"

class ParserTest < ActiveSupport::TestCase
  test "should process data request when cache is empty" do
    fetcher = Fetcher.new
    cacher = Cacher.new
    parser = Parser.new
    svc = DataService.new(fetcher, parser, cacher)

    fields = {
      "color" => ".color",
      "size" => ".size",
      "meta" => [ "author", "twitter:detail" ]
    }

    url = "foo"
    cacher.expects(:get).with(url).returns(nil)

    raw_doc = file_fixture("valid_doc.html").read
    fetcher.expects(:fetch).with(url).returns(raw_doc)

    cacher.expects(:set).once

    res = svc.process(url, fields)

    expected = {
      "color" => "blue",
      "size" => "medium",
      "meta" => {
        "author" => "Marty McFly",
        "twitter:detail" => "2 minutes read"
      }
    }
    assert_equal expected, res
  end

  test "should process data request when fully cached" do
    fetcher = Fetcher.new
    cacher = Cacher.new
    parser = Parser.new
    svc = DataService.new(fetcher, parser, cacher)

    fields = {
      "color" => ".color",
      "size" => ".size",
      "meta" => [ "author", "twitter:detail" ]
    }

    item = {
      "color" => "red",
      "size" => "large",
      "meta" => {
        "author" => "Doc McCoy",
        "twitter:detail" => "too short"
      }
    }

    url = "foo"
    cacher.expects(:get).with(url).returns(item)

    fetcher.expects(:fetch).never
    cacher.expects(:set).never

    res = svc.process(url, fields)
    assert_equal item, res
  end

  test "should process data request when partially cached" do
    fetcher = Fetcher.new
    cacher = Cacher.new
    parser = Parser.new
    svc = DataService.new(fetcher, parser, cacher)

    fields = {
      "color" => ".color",
      "price" => ".price",
      "meta" => [ "author", "twitter:detail" ]
    }

    cached = {
      "color" => "red",
      "size" => "large",
      "meta" => {
        "author" => "Doc McCoy",
        "fb:devices" => "tablet"
      }
    }

    expected = {
      "color" => "red",
      "price" => "14.4",
      "meta" => {
        "author" => "Doc McCoy",
        "twitter:detail" => "2 minutes read"
      }
    }

    url = "foo"
    cacher.expects(:get).with(url).returns(cached)

    raw_doc = file_fixture("valid_doc.html").read
    fetcher.expects(:fetch).with(url).returns(raw_doc)
    cacher.expects(:set).once

    res = svc.process(url, fields)

    assert_equal expected, res
  end

  test "should calculate item diff" do
    fetcher = Fetcher.new
    cacher = Cacher.new
    svc = DataService.new(fetcher, Parser.new, cacher)

    item = {
      "price" => "14.5",
      "color" => "blue",
      "meta" => {
        "a" =>  "value a",
        "b" => "value b"
      }
    }

    fields = {
      "color" => ".color",
      "size" => ".size",
      "meta" => [ "c", "b" ]
    }

    expected_item = {
      "color" => "blue",
      "meta" => {
        "b" => "value b"
      }
    }

    expected_missing_fields = {
      "size" => ".size",
      "meta" => [ "c" ]
    }

    item, missing_fields = svc.diff(item, fields)

    assert_equal expected_item, item
    assert_equal expected_missing_fields, missing_fields

    fetcher.expects(:fetch).never
    cacher.expects(:get).never
    cacher.expects(:set).never
  end
end
