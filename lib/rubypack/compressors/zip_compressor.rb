
module Rubypack
  module Compressors
    class ZIP
      def compress(filename:)
        IO.popen(['zip', '-r', filename, './', err: [:child, :out]]) do |out|
          yield(out)
        end
      end

      def decompress(filename:)
        IO.popen(['unzip', filename, err: [:child, :out]]) do |out|
          yield(out)
        end        
      end

      def extension
        '.zip.rpack'
      end
    end
  end
end