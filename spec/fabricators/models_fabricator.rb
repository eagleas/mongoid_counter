Fabricator :parent_resource do
end

Fabricator :resource do
end

Fabricator :resource_counter do
  downloads { 5 }
  created_at { 1.day.ago.utc }
end

