# -*- encoding : utf-8 -*-
class ResourceCounter
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :resource, polymorphic: true

  index :resource_id, unique: true
end
