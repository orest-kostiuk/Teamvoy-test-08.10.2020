# frozen_string_literal: true

class Search
  PROCESSES = { json: SearchInJson }.freeze
  def initialize(query, data)
    @query = query
    @data = data
  end

  def call
    get_process
    start_search
  end

  private

  def get_process
    extension = File.extname(@data).delete('.').to_sym
    @process = PROCESSES.include?(extension) ? PROCESSES[extension] : raise('This extension not support now')
  end

  def start_search
    @process.new(@query).call(@data)
  end
end
