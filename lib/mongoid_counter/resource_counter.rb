# -*- encoding : utf-8 -*-
class ResourceCounter
  include Mongoid::Document
  belongs_to :resource, polymorphic: true
end
