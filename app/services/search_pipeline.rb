# frozen_string_literal: true

class SearchPipeline
  attr_reader :parsed_positive_search, :parsed_negative_search

  def initialize(positive_query, negative_query, input)
    @parsed_positive_search = positive_query.output
    @parsed_negative_search = negative_query.output
    @input = input
  end

  def call
    actions.inject(@input.output) do |input, action|
      action.new(self, input).output
    end
  end

  def actions
    actions = []
    actions << NegativeSearch unless @parsed_negative_search.blank?
    actions << PositiveSearch unless @parsed_positive_search.blank?
    actions
  end

  ##################
  class NegativeSearch
    def initialize(query, input)
      @query = query.parsed_negative_search
      @input = input
    end

    def output
      @input.reject { |item| item.values.join(',').match(@query) }
    end
  end

  ###################
  class PositiveSearch
    def initialize(query, input)
      @query = query.parsed_positive_search
      @input = input
    end

    def output
      @input.select { |item| item.values.join(',').match(@query) }
    end
  end
end
