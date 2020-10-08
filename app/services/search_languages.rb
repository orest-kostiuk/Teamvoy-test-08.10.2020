
class SearchLanguages

  def initialize(query = '')
    @search_query = query
    @data = []
  end

  def call
    build_query
    query
    @result
  end

  private

  def build_query
    @negative = @search_query.scan(/-.*/)&.first
    @data << @search_query.scan(/[^"|']+/).first&.split(' ')
    @data << @search_query.scan(/[^"|']+/)[1]&.split(' ') if @search_query.scan(/[^"|']+/).count > 1
    @query = @data.flatten.map do |query|
      ".*?#{query.capitalize}" if query && !query.match(/-.*/)
    end
  end

  def query
    @result = json_data.select { |item| item.values.join(',').match(@query.join(''))}
    @result = @result.select { |item| !item.values.join(',').match(@negative.sub('-', '').capitalize)} if @negative
  end

  def json_data
    JSON.load(File.open("#{Rails.root}/data.json"))
  end

end