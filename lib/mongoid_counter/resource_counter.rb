# -*- encoding : utf-8 -*-
class ResourceCounter
  include Mongoid::Document

  embedded_in :resource, polymorphic: true
end
