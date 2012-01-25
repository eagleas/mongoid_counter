# -*- encoding : utf-8 -*-
class ResourceCounter
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :resource, polymorphic: true
end
