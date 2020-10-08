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

  def negative_filter
    json_data.reject { |item| item.values.join(',').match(negative_query) }
  end

  def query
    negative_filter.select { |item| item.values.join(',').match(build_query) }
  end

  def build_query
    @words ||= search_query.scan(QUERY_REGEXP).map { |re| get_words_for_search(re) }.join('')
  end

  def get_words_for_search(words)
    words.split(' ').map do |word|
      ".*?#{word.capitalize}" if word && !word.match(NEGATIVE_REGEXP)
    end.compact
  end

  def negative_query
    search_query.scan(NEGATIVE_REGEXP)&.first&.sub('-', '')&.capitalize || DEFAULT_REGEXP
  end

  def json_data
    JSON.load(File.open("#{Rails.root}/data.json"))
  end
end
