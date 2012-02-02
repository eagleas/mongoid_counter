Fabricator :parent_resource do
end

Fabricator :resource do
end

Fabricator :resource_counter do
  id { BSON::ObjectId.from_time(1.day.ago.utc) }
  downloads { 5 }
end

