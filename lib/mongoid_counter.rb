# -*- encoding : utf-8 -*-
require 'mongoid_counter/resource_counter'
module Mongoid # :nodoc:
  module Counter # :nodoc:
    extend ActiveSupport::Concern

    module ClassMethods
      def has_counters(*args)
	cattr_accessor :counters, :counters_options

	self.counters_options = HashWithIndifferentAccess.new(args.extract_options!)
	self.counters = args

	embeds_many :resource_counters, as: :resource

	args.each do |counter_name|
	  field "cached_#{counter_name}", type: Integer
	end
	args.each do |field_name|
	  begin
	    ::ResourceCounter.class_eval <<-FIELDS, __FILE__, __LINE__ + 1
	    field :#{field_name}, type: Integer
	    FIELDS
	  rescue Errors::InvalidField
	  end
	end
      end
    end

    module InstanceMethods

      def add_count(sym, increment = 1)
	if counters_options["#{sym}_method"]
	  inc("cached_#{sym}", increment)
	else
	  counter = resource_counters.
	    where(:created_at.gte => Time.now.utc.beginning_of_day).first
	  if counter
	    send("cached_#{sym}=", (self["cached_#{sym}"] || 0) + increment)
	    counter.send("#{sym}=", (counter[sym] || 0) + increment)
	  else
	    send("cached_#{sym}=", (self["cached_#{sym}"] || 0) + increment)
	    #WTF? resource_counter below is available for update ONLY after parent instance is saved
	    #due to this case we can't use #inc for updating cached_column
	    resource_counters.create(sym => increment, created_at: Time.now)
	  end
	  timeless.save!(validate: false)
	end
      end

      def get_count(sym, cached = true)
	if cached
	  self["cached_#{sym}".to_sym] || get_count(sym, false)
	else
	  fresh = \
	    if method = counters_options["#{sym}_method"]
	      send(method)
	  else
	    resource_counters.map(&sym).compact.reduce(:+)
	  end || 0
	  set("cached_#{sym}", fresh) if self.send("cached_#{sym}") != fresh
	  fresh
	end
      end

    end
end
end
