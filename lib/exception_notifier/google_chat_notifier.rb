class ExceptionNotifier
  class GoogleChatNotifier
    cattr_accessor :google_chat_available, true

    def initialize(options)
      begin
        return unless google_chat_available
        @webhook_url = options[:webhook_url]
        @user_ids = options[:user_ids] || {}
      rescue
        @webhook_url = nil
        @user_ids = {}
      end
    end

    def background_exception_notification(exception, data)
      if @webhook_url
        @current_time = Time.zone.now
        @task_name = data[:rake_command_line]

        HTTParty.post(
          "#{ @webhook_url }#{ @current_time.to_i }",
          headers: {
            'Content-Type' => 'application/json'
          },
          body: {
            text: exception_messsage(exception)
          }.to_json
        )
      end
    end

    def exception_messsage(exception)
      message = "====== #{ @current_time.strftime("%d %b %Y (%I:%M:%S %P)") } ======"
      message << "\n\n"
      message << "====== Exception In Task #{ @task_name } ======"
      message << "\n\n"
      message << exception.inspect
      message << "\n\n"
      message << exception.backtrace.join("\n")
      message << "\n\n"
      unless @user_ids.empty?
        @user_ids.each do |name, user_id|
          message << "<users/#{user_id}>\n"
        end
      end
      message
    end
  end
end

ExceptionNotifier::GoogleChatNotifier.google_chat_available = Gem.loaded_specs.keys.include?('httparty')
