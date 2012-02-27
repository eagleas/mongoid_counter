# -*- encoding : utf-8 -*-
module Mongoid # :nodoc:
  module Counter # :nodoc:
    extend ActiveSupport::Concern

    module ClassMethods
      def has_counters(*args)
        cattr_accessor :counters, :counters_options

        self.counters_options = HashWithIndifferentAccess.new(args.extract_options!)
        self.counters = args

        field :cnt, type: Hash

        args.each do |counter_name|
          field "cached_#{counter_name}", type: Integer
        end
      end
    end

    def add_count(sym, increment = 1)
      unless counters_options["#{sym}_method"]
        date = Time.now.utc.to_date.to_time.to_i.to_s
        if cnt[date]
          inc("cnt.#{date}.#{sym[0,2]}", increment)
          cnt[date][sym[0,2]] += increment
        else
          set("cnt.#{date}", {sym[0,2] => increment}) # NON thread safe!
          cnt[date] = { sym[0,2] => increment }
        end
      end
      inc(aliased_fields["cached_#{sym}"] ||"cached_#{sym}" , increment)
    end

    def get_count(sym, cached = true)
      if cached
        self.send("cached_#{sym}") || get_count(sym, false)
      else
        fresh = \
          if method = counters_options["#{sym}_method"]
            send(method)
          else
            cnt.inject(0) { |sum, e| sum + e[1][sym[0,2]].to_i }
          end || 0
        if not fresh.zero? and self.send("cached_#{sym}") != fresh
          set(aliased_fields["cached_#{sym}"] ||"cached_#{sym}", fresh)
        end
        fresh
      end
    end

  end
end
