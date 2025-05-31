class ApplicationController < ActionController::API
  rescue_from ActionDispatch::Http::Parameters::ParseError, with: :invalid_json

  private

  def invalid_json
    render json: { error: "malformed JSON" }, status: 400
  end
end
