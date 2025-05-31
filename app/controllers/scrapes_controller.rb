class ScrapesController < ApplicationController
  def data
    result = data_service.process url, fields

    render json: result
  rescue FetchError => e
    render json: { error: e.message }, status: 422
  end

  private

  def data_params
    params.expect(scrape: [ :url, fields: {} ])
  end

  def data_service
    DataService.new(Fetcher.new, Parser.new, Cacher.new)
  end

  def fields
    data_params[:fields].to_h.with_indifferent_access
  end

  def url
    data_params[:url]
  end
end
