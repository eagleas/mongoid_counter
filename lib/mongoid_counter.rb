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
      if counters_options["#{sym}_method"]
        inc("cached_#{sym}", increment)
      else
        date = Time.now.utc.to_date.to_time.to_i.to_s
        if cnt[date]
          inc("cnt.#{date}.#{sym}", increment)
        else
          set("cnt.#{date}", {sym => increment}) # NON thread safe!
        end
        inc("cached_#{sym}", increment)
        reload                      # <---- potentially bottleneck
      end
    end

    def get_count(sym, cached = true)
      if cached
        self[:"cached_#{sym}"] || get_count(sym, false)
      else
        fresh = \
          if method = counters_options["#{sym}_method"]
            send(method)
          else
            cnt.inject([]){|s, v| s << v[1][sym.to_s] }.compact.reduce(:+)
          end || 0
        set("cached_#{sym}", fresh) if self.send("cached_#{sym}") != fresh
        fresh
      end
    end

  end
end
