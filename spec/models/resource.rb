# -*- encoding : utf-8 -*-
class Resource
  include Mongoid::Document
  include Mongoid::Counter

  belongs_to :parent_resource

  has_counters :views, :downloads, :samples, :samples_method => :calculate

  private
  def calculate
    999
  end
end
