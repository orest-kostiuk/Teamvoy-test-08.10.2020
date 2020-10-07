class ProgrammingLanguage
  include ActiveModel::Model
  include ActiveModel::Attributes # not included in the above
  attribute :awesomeness, :integer, default: 0
  # ...
  #
  def self.all
    data = JSON.parse(File.open('/path/to/file.json'))
    data.map do |hash|
      new(hash)
    end
  end
end
