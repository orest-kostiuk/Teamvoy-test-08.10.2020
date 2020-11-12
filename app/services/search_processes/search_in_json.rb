# frozen_string_literal: true

class SearchProcesses::SearchInJson
  def initialize(query)
    @search_query = query
  end

  def call(json_data)
    PositiveSearch.new(NegativeSearch.new(QueryParser.new(@search_query), PrepareData.new(json_data))).output
  end

  ##############
  class PrepareData
    attr_accessor :json_data
    def initialize(data)
      @json_data = data
    end

    def output
      JSON.load(json_data)
    end
  end

  #################
  class QueryParser
    NEGATIVE_REGEXP = /-.*/.freeze
    QUERY_REGEXP = /[^"|']+/.freeze
    DEFAULT_REGEXP = /.^/.freeze

    attr_accessor :query

    def initialize(data)
      @query_string = data
    end

    def output
      parse_query
    end

    private


    def parse_query
      @query = @query_string.scan(QUERY_REGEXP).map { |re| get_words_for_search(re) }.join('')
      @negative_query = @query_string.scan(NEGATIVE_REGEXP)&.first&.sub('-', '')&.capitalize || DEFAULT_REGEXP
    end

    def get_words_for_search(words)
      words.split(' ').map do |word|
        ".*?#{word.capitalize}" if word && !word.match(NEGATIVE_REGEXP)
      end.compact
    end
  end

  ##################
  class NegativeSearch
    attr_accessor :parsed_query

    def initialize(query, data)
      @parsed_query = query
      @data = data
    end

    def output
      @data.output.reject { |item| item.values.join(',').match(parsed_query.output) }
    end
  end

  ###################
  class PositiveSearch
    def initialize(data)
      @data = data
    end

    def output
      @data.output.select { |item| item.values.join(',').match(@data.parsed_query.query) }
    end
  end
end
