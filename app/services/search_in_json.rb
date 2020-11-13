# frozen_string_literal: true

class SearchInJson
  attr_accessor :json_data, :parsed_positive_search, :parsed_negative_search

  def initialize(search_query, json_data)
    @parsed_positive_search = ParsePositiveQuery.new(search_query)
    @parsed_negative_search = ParseNegativeQuery.new(search_query)
    @json_data = PrepareData.new(json_data)
  end

  def call
    PositiveSearch.new(NegativeSearch.new(self)).output
  end

  ##############
  class PrepareData
    def initialize(data)
      @json_data = data
    end

    def output
      JSON.load(@json_data)
    end
  end

  #################
  class ParsePositiveQuery
    NEGATIVE_REGEXP = /-.*/.freeze
    QUERY_REGEXP = /[^"|']+/.freeze

    def initialize(query_string)
      @query_string = query_string
    end

    def output
      parse_query
    end

    private

    def parse_query
      @query = @query_string.scan(QUERY_REGEXP).map { |re| get_words_for_search(re) }.join('')
    end

    def get_words_for_search(words)
      words.split(' ').map do |word|
        ".*?#{word.capitalize}" if word && !word.match(NEGATIVE_REGEXP)
      end.compact
    end
  end

  ######################
  class ParseNegativeQuery
    NEGATIVE_REGEXP = /-.*/.freeze
    DEFAULT_REGEXP = /.^/.freeze

    def initialize(query_string)
      @query_string = query_string
    end

    def output
      parse_query
    end

    private

    def parse_query
      @negative_query = @query_string.scan(NEGATIVE_REGEXP)&.first&.sub('-', '')&.capitalize || DEFAULT_REGEXP
    end
  end

  ##################
  class NegativeSearch
    attr_accessor :data

    def initialize(data)
      @data = data
    end

    def output
      @data.json_data.output.reject { |item| item.values.join(',').match(@data.parsed_negative_search.output) }
    end
  end

  ###################
  class PositiveSearch
    def initialize(data)
      @data = data
    end

    def output
      @data.output.select { |item| item.values.join(',').match(@data.data.parsed_positive_search.output) }
    end
  end
end
