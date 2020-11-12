# frozen_string_literal: true

class SearchProcesses::SearchInJson
  def initialize(query)
    @search_query = query
  end

  def call(json_data)
    prepare_data(json_data)
    res = StringParser.new(@search_query).process
    Searching.new(res, @json_data).process
  end

  private

  def prepare_data(json_data)
    @json_data = JSON.load(json_data)
  end


  class StringParser
    NEGATIVE_REGEXP = /-.*/.freeze
    QUERY_REGEXP = /[^"|']+/.freeze
    DEFAULT_REGEXP = /.^/.freeze

    def initialize(string)
      @string = string
    end

    def process
      parse_query
      build_query
    end

    private

    def build_query
      [@query, @negative_query]
    end

    def parse_query
      @query = @string.scan(QUERY_REGEXP).map { |re| get_words_for_search(re) }.join('')
      @negative_query = @string.scan(NEGATIVE_REGEXP)&.first&.sub('-', '')&.capitalize || DEFAULT_REGEXP
    end

    def get_words_for_search(words)
      words.split(' ').map do |word|
        ".*?#{word.capitalize}" if word && !word.match(NEGATIVE_REGEXP)
      end.compact
    end
  end


  class Searching

    def initialize(parsed_string, data)
      @parsed_string = parsed_string
      @data = data
    end

    def process
      @result = NegativeSearch.new.negative_filter(@parsed_string[1], @data)
      BasicSearch.new.query(@parsed_string[0], @result)
    end

    class NegativeSearch
      def negative_filter(query, data)
        data.reject { |item| item.values.join(',').match(query) }
      end
    end

    class BasicSearch
      def query(query, data)
        data.select { |item| item.values.join(',').match(query) }
      end
    end
  end
end
