# -*- encoding : utf-8 -*-
class ParentResource
  include Mongoid::Document
  include Mongoid::Counter

  embeds_many :resource

  private
  def calculate
    999
  end
end
