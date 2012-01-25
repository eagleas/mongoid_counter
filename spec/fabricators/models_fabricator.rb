Fabricator :resource do
  cached_downloads { nil }
  cached_views { nil }
end

Fabricator :resource_counter do
  resource_type { 'Resource' }
  downloads { 5 }
  created_at { Time.now.yesterday.beginning_of_day }
end

