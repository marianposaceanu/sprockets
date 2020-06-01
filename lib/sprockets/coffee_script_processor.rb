# frozen_string_literal: true
require 'sprockets/autoload'
require 'sprockets/source_map_utils'

module Sprockets
  # Processor engine class for the CoffeeScript compiler.
  # Depends on the `coffee-script` and `coffee-script-source` gems.
  #
  # For more infomation see:
  #
  #   https://github.com/rails/ruby-coffee-script
  #
  module CoffeeScriptProcessor
    VERSION = '2'

    def self.cache_key
      puts name
      @cache_key ||= "#{name}:".freeze
    end

    def self.call(input)
      data = input[:data]

      { data: input[:data], map: nil }
    end
  end
end
