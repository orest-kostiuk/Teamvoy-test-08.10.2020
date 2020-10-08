# frozen_string_literal: true

class SearchLanguages
  NEGATIVE_REGEXP = /-.*/.freeze
  QUERY_REGEXP = /[^"|']+/.freeze
  DEFAULT_REGEXP = /.^/.freeze

  attr_reader :search_query

  def initialize(query = '')
    @search_query = query
  end

  def call
    query
  end

  private

  def query
    result = json_data.reject { |item| item.values.join(',').match(negative_query) }
    result.select { |item| item.values.join(',').match(build_query.join('')) }
  end

  def build_query
    data = []
    data << search_query.scan(QUERY_REGEXP).first&.split(' ')
    data << search_query.scan(QUERY_REGEXP)[1]&.split(' ') if search_query.scan(QUERY_REGEXP).count > 1
    data.flatten.map { |query| ".*?#{query.capitalize}" if query && !query.match(NEGATIVE_REGEXP) }
  end

  def negative_query
    search_query.scan(NEGATIVE_REGEXP)&.first&.sub('-', '')&.capitalize || DEFAULT_REGEXP
  end

  def json_data
    JSON.load(File.open("#{Rails.root}/data.json"))
  end
end
