class HomeController < ApplicationController
  before_action :force_json, only: :search

  def index
    @data = []
  end

  def search
    @languages = SearchLanguages.new(params['q']).call
  end

  private

  def force_json
    request.format = :json
  end
end
