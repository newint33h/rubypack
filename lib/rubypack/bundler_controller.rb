
module Rubypack
  class BundlerController
    def initialize(path:)
      @path = path
    end

    def package
      begin
        Dir.chdir(@path) do 
          IO.popen(['bundle', 'package', '--all-platforms', '--all', err: [:child, :out]]) do |out|
            yield(out)
          end
          fail("bundle package failed: #{$?.exitstatus}") unless $?.exitstatus == 0
          true
        end
      rescue => error
        fail("Error executing bundle package: #{error.message}")
      end
    end

    def install
      begin
        Dir.chdir(@path) do 
          IO.popen(['bundle', 'install', '--local', '--deployment', err: [:child, :out]]) do |out|
            yield(out)
          end
          fail("bundle install failed: #{$?.exitstatus}") unless $?.exitstatus == 0
          true
        end
      rescue => error
        fail("Error executing bundle install: #{error.message}")
      end
    end
  end
end