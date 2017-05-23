
module Rubypack
  # Class used to supress all message to the stdout/stderr.
  class QuietOutput
    def step(action)
      status(action)
      result = yield
      status('  [ OK ]')
      result
    rescue => exception
      error('  [ FAIL ]', exception.message)
      verbose(exception.backtrace.join("\n"))
      nil
    end

    def status(*messages)
      # nothing to do
    end

    def verbose(*messages)
      # nothing to do
    end

    def error(*messages)
      # nothing to do
    end
  end

  # Class used to display all the normal messages to stdout and stderr.
  class DefaultOutput < QuietOutput
    def status(*messages)
      $stdout.puts(messages.join(' '))
    end

    def error(*messages)
      $stderr.puts(messages.join(' '))
    end
  end

  # Class used to display all the messages to stdout and stderr including the debug information
  class VerboseOutput < DefaultOutput
    def verbose(*messages)
      $stdout.puts(messages.join(' '))
    end
  end
end