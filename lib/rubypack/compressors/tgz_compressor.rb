
module Rubypack
  module Compressors
    class TGZ
      def compress(filename:)
        IO.popen(['tar', '-zcvf', filename, './', err: [:child, :out]]) do |out|
          yield(out)
        end
      end

      def decompress(filename:)
        IO.popen(['tar', '-zxvf', filename, err: [:child, :out]]) do |out|
          yield(out)
        end        
      end

      def extension
        '.tgz.rpack'
      end
    end
  end
end