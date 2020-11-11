class HomeController < ApplicationController
  before_action :force_json, only: :search

  def index; end

  def search
    json_data = File.open("#{Rails.root}/data.json")
    @languages = Search.new(params['q'], json_data).call
  end

  private

  def force_json
    request.format = :json
  end
end
