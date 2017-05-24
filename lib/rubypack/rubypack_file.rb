
module Rubypack
  class RubypackFile
    DEFAULT_FILENAME = '.rubypack'

    attr_accessor :path, :filename

    def initialize(filename:, output:)
      fail("File not found: #{filename}") unless File.exists?(filename)
      @filename = File.basename(filename)
      @path = File.dirname(filename)
      @output = output
      read!
    end

    def read!
      instance_exec { eval(File.read(File.join(@path, @filename))) }
    end

    def name(name)
      @output.status(' Name:', name)
      @name = name
    end

    def version(version)
      @output.status(' Version:', version)
      @version = version
    end

    def output_filename
      "#{@name}-#{@version}"
    end

    def include(*args)
      @rules = [] unless defined?(@rules)
      args.each { |entry| @rules << { action: :include, filter: entry } }
    end

    def exclude(*args)
      @rules = [] unless defined?(@rules)
      args.each { |entry| @rules << { action: :exclude, filter: entry } }
    end

    def format_rule(rule, files)
      @output.status(" Action: #{rule[:action]}, Filter: #{rule[:filter]}")
      icon = (rule[:action] == :include) ? '  +' : '  -'
      files.each { |file| @output.verbose(icon, file) }
    end

    def list_files
      Dir.chdir(@path) do

      # If not rules were defined, include all by default
      unless defined?(@rules)
        files = Dir['**/**']        
        format_rule({ action: :include, filter: '**/**' }, files)
        return ffiles
      end

      # Determinate if the package must start with all files or with none
      action = @rules.first[:action]
      if action == :include
        files = []
      elsif action == :exclude
        files = Dir['**/**']
        format_rule({ action: :include, filter: '**/**' }, files)
      else
        fail("Action not implemented: #{action}")
      end

      # Include/exclude based on the rules
      @rules.each do |rule|
        if rule[:action] == :include
          filtered_files = Dir[rule[:filter]]
          files |= filtered_files
          format_rule(rule, filtered_files)
        elsif rule[:action] == :exclude
          filtered_files = Dir[rule[:filter]]
          files -= filtered_files
          format_rule(rule, filtered_files)
        else
          fail("Action not implemented: #{rule[:action]}")
        end
      end

      # Remove directories
      files.reject! { |file| File.directory?(file) }

      # Sort the file names
      files.sort
      end
    end

  end
end