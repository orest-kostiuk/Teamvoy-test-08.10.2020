# frozen_string_literal: true

class SearchProcesses::Base
  NEGATIVE_REGEXP = /-.*/.freeze
  QUERY_REGEXP = /[^"|']+/.freeze
  DEFAULT_REGEXP = /.^/.freeze

  attr_reader :search_query, :json_data

  def initialize(query)
    @search_query = query
  end

  def call(json_data)
    prepare_data(json_data)
    query
  end

  private

  def prepare_data(json_data); end

  def negative_filter; end

  def query; end

  def build_query; end

  def match_element; end

  def get_words_for_search; end

  def negative_query; end
end
