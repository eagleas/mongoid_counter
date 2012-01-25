Fabricator :resource do
  cached_downloads { nil }
  cached_views { nil }
end

Fabricator :resource_counter do
  resource_type { 'Resource' }
  counter_name { 'downloads' }
  count { 5 }
  created_at { Time.now.beginning_of_day }
end

