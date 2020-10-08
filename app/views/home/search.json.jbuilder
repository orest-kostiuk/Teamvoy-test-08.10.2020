json.languages do
  json.array!(@languages) do |language|
    json.name language['Name']
    json.type language['Type']
    json.designed_by language['Designed by']
  end
end