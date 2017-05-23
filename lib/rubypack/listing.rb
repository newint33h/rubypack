require 'fileutils'

module Rubypack
  class Listing
    def initialize(options)
      @options = options
      @output = VerboseOutput.new
    end

    def list!
      pack = RubypackFile.new(filename: @options[:config], output: @output)
      pack.include(@options[:config])
      pack.include('vendor/cache/*')
      files = pack.list_files
      @output.status(' Files count:', files.count)
    end

  end
end