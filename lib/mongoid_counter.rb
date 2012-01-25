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

        has_many :resource_counters, :as => :resource, :dependent => (counters_options[:dependent] || :delete)

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
        unless counters_options["#{sym}_method"]
          if counter = resource_counters.where(:counter_name => sym.to_s).where(:created_at.gte => Time.now.beginning_of_day).first
            counter.inc(sym, increment)
          else
            resource_counters << ResourceCounter.new(:count => increment, :counter_name => sym.to_s)
          end
        end
        self.inc("cached_#{sym}", increment)
      end

      def get_count(sym, cached = true)
        if cached
          self.send("cached_#{sym}".to_sym) || get_count(sym, false)
        else
          fresh = \
            if method = counters_options["#{sym}_method"]
              self.send(method)
            else
              resource_counters.only(:counter_name, :count).where(:counter_name => sym.to_s).sum(:count).to_i
            end || 0
          self.set("cached_#{sym}", fresh) if self.send("cached_#{sym}") != fresh
          fresh
        end
      end

    end
  end
end
