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
          field :"cached_#{counter_name}", type: Integer
        end
        args.each do |field_name|
          ::ResourceCounter.class_eval <<-FIELDS, __FILE__, __LINE__ + 1
            field :#{field_name}, type: Integer
          FIELDS
        end
      end
    end

    module InstanceMethods

      def add_count(sym, increment = 1)
        if counters_options["#{sym}_method"]
          self.inc("cached_#{sym}", increment)
        else
          self.send(:"cached_#{sym}=", (self["cached_#{sym}".to_sym] || 0) + increment)
          counter = resource_counters.
            where(:created_at.gte => Time.now.beginning_of_day, sym.gt => 0).first
          if counter
            counter.send(:"#{sym}=", (counter[sym] || 0) + increment)
          else
            resource_counters.build(sym => increment, created_at: Time.now)
          end
          save(validate: false)
        end
      end

      def get_count(sym, cached = true)
        if cached
          self["cached_#{sym}".to_sym] || get_count(sym, false)
        else
          fresh = \
            if method = counters_options["#{sym}_method"]
              self.send(method)
            else
              resource_counters.map(&sym).compact.reduce(:+)
            end || 0
          self.set("cached_#{sym}", fresh) if self.send("cached_#{sym}") != fresh
          fresh
        end
      end

    end
  end
end
