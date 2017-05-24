require_relative 'compressors/all'
require 'fileutils'

module Rubypack
  class Compressor

    def initialize(format:, output:)
      @format = format
      @output = output

      @compressor = case format
      when 'tgz'
        Compressors::TGZ.new
      when 'zip'
        Compressors::ZIP.new
      else
        fail("Unknown compressor: #{format}")
      end
    end

    def compress!(path:, output_filename:, overwrite:)
      fail("File already exists: #{output_filename}") if !overwrite && File.exists?(output_filename)
      fail("Directory not found: #{path}") unless File.directory?(path)
      output_directory = File.dirname(output_filename)
      fail("Directory not found: #{output_directory}") unless File.directory?(output_directory)

      begin
        filename = File.expand_path(output_filename + @compressor.extension)
        Dir.chdir(path) do
          @compressor.compress(filename: filename) do |out|
            while line = out.gets do
              @output.verbose(' >', line)
            end
          end
        end
      end

      @output.status(' File created: ', filename)
    rescue => exception
      @output.error(exception.message)
      fail('Compression canceled')
    end

    def decompress!(filename:, directory:)
      fail("File not found: #{filename}") unless File.exists?(filename)
      fail("Directory already exists: #{directory}") if File.directory?(directory)

      FileUtils.mkdir_p(directory)

      begin
        full_filename = File.expand_path(filename)
        Dir.chdir(directory) do
          @compressor.decompress(filename: full_filename) do |out|
            while line = out.gets do
              @output.verbose(' >', line)
            end
          end
        end
      end

      @output.status(' Directory created: ', directory)
    rescue => exception
      @output.error(exception.message)
      fail('Decompression canceled')
    end
  end
end