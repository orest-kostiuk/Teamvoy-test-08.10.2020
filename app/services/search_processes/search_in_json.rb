# frozen_string_literal: true

class SearchProcesses::SearchInJson < SearchProcesses::Base
  private

  def prepare_data(json_data)
    @json_data = JSON.load(json_data)
  end

  def negative_filter
    json_data.reject { |item| match_element(item, negative_query) }
  end

  def query
    negative_filter.select { |item| match_element(item, build_query) }
  end

  def build_query
    search_query.scan(QUERY_REGEXP).map { |re| get_words_for_search(re) }.join('')
  end

  def match_element(elem, query)
    elem.values.join(',').match(query)
  end

  def get_words_for_search(words)
    words.split(' ').map do |word|
      ".*?#{word.capitalize}" if word && !word.match(NEGATIVE_REGEXP)
    end.compact
  end

  def negative_query
    search_query.scan(NEGATIVE_REGEXP)&.first&.sub('-', '')&.capitalize || DEFAULT_REGEXP
  end
end
