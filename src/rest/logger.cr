require "http/server/handler"
require "logger"
require "colorize"
require "time_format"

module Rest
  # `HTTP::Handler` which logs requests colorfully into specified *logger*.
  #
  # ```
  # require "rest/logger"
  # logger = Rest::Logger.new(Logger.new(STDOUT))
  #
  # #   INFO -- :    GET /users 200 102μs
  # #   INFO -- :    GET /favicon.ico 404 52μs
  # #   INFO -- :   POST /users 201 3.74ms
  # ```
  class Logger
    include HTTP::Handler

    def initialize(@logger : ::Logger)
    end

    def call(context)
      time = Time.now

      begin
        call_next(context)
      ensure
        time = TimeFormat.auto(Time.now - time).colorize(:dark_gray)

        color = :red
        case context.response.status_code
        when 100..199
          color = :cyan
        when 200..299
          color = :green
        when 300..399
          color = :yellow
        end

        method = context.request.method.rjust(6).colorize(color).mode(:bold)
        resource = context.request.resource.colorize(color)
        status_code = context.response.status_code.colorize(color).mode(:bold)

        @logger.info("#{method} #{resource} #{status_code} #{time}")
      end
    end
  end
end