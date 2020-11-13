# frozen_string_literal: true

class SearchEngine

  class JsonParser
    def initialize(data)
      @json_data = data
    end

    def output
      JSON.load(@json_data)
    end
  end

  PARSERS = { json: JsonParser }.freeze

  def initialize(query, data)
    @query = query
    @data = data
  end

  def call
    chose_parse
    SearchPipeline.new(ParsePositiveQuery.new(@query), ParseNegativeQuery.new(@query), @parser.new(@data)).call
  end

  def chose_parse
    extension = File.extname(@data).delete('.').to_sym
    @parser = PARSERS.include?(extension) ? PARSERS[extension] : raise('This extension not support now')
  end

  class ParsePositiveQuery
    NEGATIVE_REGEXP = /-.*/.freeze
    QUERY_REGEXP = /[^"|']+/.freeze

    def initialize(query_string)
      @query_string = query_string
    end

    def output
      @query_string.scan(QUERY_REGEXP).map { |re| get_words_for_search(re) }.join('')
    end

    private

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
      @query_string.scan(NEGATIVE_REGEXP)&.first&.sub('-', '')&.capitalize || DEFAULT_REGEXP
    end
  end
end

