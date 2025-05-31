require "test_helper"

class ParserTest < ActiveSupport::TestCase
  def setup
    @parser = Parser.new
  end

  test "should parse correctly" do
    raw_doc = file_fixture("valid_doc.html").read
    res = @parser.parse(raw_doc, { "info" => "#info", "cost" => ".price" })

    assert_equal({ "info" => "whatever", "cost" => "14.4" }, res)
  end

  test "should return nothing on nil doc" do
    res = @parser.parse(nil, { "info" => "#info", "cost" => ".price" })

    assert_equal({ "info" => nil, "cost" => nil }, res)
  end

  test "should return nothing on malformed doc" do
    res = @parser.parse("fasdfasdfg", { "info" =>  "#info", "cost" => ".price" })

    assert_equal({ "info" => nil, "cost" => nil }, res)
  end

  test "should parse meta" do
    raw_doc = file_fixture("valid_doc.html").read
    res = @parser.parse(raw_doc, { "info" => "#info", "cost" =>  ".price", "meta" => [ "twitter:detail", "author" ] })
    expected = {
      "info" => "whatever",
      "cost" => "14.4",
      "meta" => {
        "twitter:detail" => "2 minutes read",
        "author" => "Marty McFly"
      }
    }
    assert_equal(expected, res)
  end
end
