require 'fileutils'

module Rubypack
  class Builder
    def initialize(options)
      @options = options
      @output = if options[:verbose]
                  VerboseOutput.new
                elsif options[:quiet]
                  QuietOutput.new
                else
                  DefaultOutput.new
                end
      @overwrite = !options[:no_overwrite]
      @output_directory = options[:output_directory]
    end

    def build!
      pack = read_rubypack_file
      return false unless pack

      download_success = download_gems(pack)
      return false unless download_success

      files = generate_list_of_files(pack)
      return false unless files

      Dir.mktmpdir do |output_directory|
        copy_files(pack, files, output_directory)
        create_package(pack, output_directory)
      end

      true
    rescue => exception
      @output.error(exception.message)
      @output.verbose(exception.backtrace.join("\n"))
      false
    end

    private

    def read_rubypack_file
      @output.step("Reading #{@options[:config]} file...") do
        RubypackFile.new(filename: @options[:config], output: @output)
      end
    end

    def download_gems(pack)
      @output.step('Downloading gems...') do
        bundler = BundlerController.new(path: pack.path)
        bundler.package do |out|
          while line = out.gets do
            @output.verbose(' >', line)
          end
        end
      end
    end

    def generate_list_of_files(pack)
      @output.step('Generating list of files...') do
        pack.include(pack.filename)
        pack.include('Gemfile')
        pack.include('Gemfile.lock')
        pack.include('vendor/cache/*')
        all_files = pack.list_files
        @output.status(' Files count:', all_files.count)
        all_files
      end
    end

    def copy_files(pack, files, output_directory)
      @output.step('Creating copy of files...') do
        @output.verbose(' Temporal path:', output_directory)
        FileUtils.mkdir_p(output_directory)
        files.each do |file|
          new_file = File.join(output_directory, file)
          directory = File.dirname(new_file)
          FileUtils.mkdir_p(directory) unless Dir.exists?(directory)
          @output.verbose(' =', file)
          FileUtils.copy_entry(File.join(pack.path, file), new_file)
        end
      end
    end

    def create_package(pack, output_directory)
      @output.step('Creating package...') do
        compressor = Compressor.new(
          format: @options[:compressor],
          output: @output)
        compressor.compress!(
          path: output_directory,
          output_filename: File.join(@output_directory, pack.output_filename),
          overwrite: @overwrite)
      end
    end    
  end
end