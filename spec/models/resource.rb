# -*- encoding : utf-8 -*-
class Resource
  include Mongoid::Document
  include Mongoid::Counter

  embedded_in :parent_resource

  has_counters :views, :downloads, :samples, :samples_method => :calculate

  private
  def calculate
    999
  end
end
