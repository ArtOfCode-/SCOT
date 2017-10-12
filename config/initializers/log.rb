ActionController::Instrumentation.class_eval do
  def process_action(*args)
    raw_payload = {
      controller: self.class.name,
      action:     self.action_name,
      params:     request.filtered_parameters,
      format:     request.format.try(:ref),
      method:     request.method,
      path:       (request.fullpath rescue "unknown"),
      request:    request
    }

    ActiveSupport::Notifications.instrument("start_processing.action_controller", raw_payload.dup)

    ActiveSupport::Notifications.instrument("process_action.action_controller", raw_payload) do |payload|
      result = super
      append_info_to_payload(request_id: request.request_id)
      result
    end
  end
end

class NoPrefixFormatter < ActiveSupport::Logger::SimpleFormatter
  def call(severity, timestamp, _progname, message)
    "#{message}\n"
  end
end

module CustomLogger
  @loggers = {}
  %i{action_controller action_view active_record}.each do |v|
    @loggers[v] = Logger.new("#{Rails.root}/log/#{v}.log")
    @loggers[v].formatter = NoPrefixFormatter.new
  end

  def self.loggers
    @loggers
  end

  def self.logs(logger)
    JSON.parse("[#{File.read(File.join(Rails.root,"log/#{logger.to_s}.log")).split("\n").tap(&:shift).join(",")}]")
  end
end

{
  action_controller: [
    %r{process_action.action_controller},
    %r{redirect_to.action_controller},
    %r{halted_callback.action_controller},
  ],
  action_view: [%r{action_view}],
  active_record: [%r{active_record}]
}.each do |logger, targets|
  targets.each do |target|
    ActiveSupport::Notifications.subscribe target do |name, started, finished, unique_id, data|
      CustomLogger.loggers[logger].info(
        JSON.generate({
          name: name,
          started: started,
          duration: finished-started,
          thread: Thread.current.object_id,
          data: data
        })
      )
    end
  end
end