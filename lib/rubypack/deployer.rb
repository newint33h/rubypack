require 'fileutils'

module Rubypack
  class Deployer
    def initialize(options)
      @options = options
      @output = if options[:verbose]
                  VerboseOutput.new
                elsif options[:quiet]
                  QuietOutput.new
                else
                  DefaultOutput.new
                end

      @filename = options[:filename]
      @directory = options[:directory]
    end

    def deploy!
      success = unpack_file
      return unless success

      success = install_gems
      return false unless success

      true
    rescue => exception
      @output.error(exception.message)
      verbose(exception.backtrace.join("\n"))
      false
    end

    private

    def unpack_file
      @output.step('Unpacking file...') do
        if @options[:compressor]
          format = @options[:compressor]
        elsif @filename =~ /\.([a-z]+)\.rpack$/
          format = $1
        else
          @output.error("Unknown package format")
          return false
        end

        compressor = Compressor.new(
          format: format,
          output: @output)
        compressor.decompress!(
          filename: @filename,
          directory: @directory)

        true
      end
    end

    def install_gems
      @output.step('Installing gems...') do
        bundler = BundlerController.new(path: @directory)
        bundler.install do |out|
          while line = out.gets do
            @output.verbose(' >', line)
          end
        end
      end
    end

  end
end