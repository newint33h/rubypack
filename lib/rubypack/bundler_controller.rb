
module Rubypack
  class BundlerController
    def initialize(path:)
      @path = path
    end

    def package
      begin
        old_pwd = Dir.pwd
        Dir.chdir(@path)
        IO.popen(['bundle', 'package', '--all-platforms', err: [:child, :out]]) do |out|
          yield(out)
        end
        fail("bundle package failed: #{$?.exitstatus}") unless $?.exitstatus == 0
        true
      rescue => error
        fail("Error executing bundle package: #{error.message}")
      ensure
        Dir.chdir(old_pwd)
      end
    end

    def install
      begin
        old_pwd = Dir.pwd
        Dir.chdir(@path)
        IO.popen(['bundle', 'install', '--local', '--deployment', err: [:child, :out]]) do |out|
          yield(out)
        end
        fail("bundle package failed: #{$?.exitstatus}") unless $?.exitstatus == 0
        true
      rescue => error
        fail("Error executing bundle package: #{error.message}")
      ensure
        Dir.chdir(old_pwd)
      end
    end
  end
end