# frozen_string_literal: true

module ChatGPT
  # The client for the OpenAI ChatGPT API
  class Client
    def initialize(api_key: ENV["OPENAI_API_KEY"], system_prompt: nil)
      if api_key.nil? || api_key.empty?
        raise Error, "You must provide an API token or set the OPENAI_API_KEY environment variable"
      end

      @api_key = api_key
      @system_prompt = system_prompt
      @history = []
    end

    def autocomplete(message)
      result = request(message)

      choice = result["choices"][0]
      text = choice["message"]["content"].strip
      complete = choice["finish_reason"] == "stop"

      add_history("assistant", text)

      { text: text, complete: complete }
    end

    def reset
      @history = []
    end

    def shift_history
      @history.shift(2)
    end

    private

    def http
      @http ||= begin
        uri = URI("https://api.openai.com")

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http
      end
    end

    def request(message)
      req = Net::HTTP::Post.new("/v1/chat/completions")
      req["Authorization"] = "Bearer #{@api_key}"
      req["Content-Type"] = "application/json"

      add_history("user", message)

      req.body = build_body.to_json

      extract_response(http.request(req))
    end

    def extract_response(response)
      raise Error, "Error: #{response.code} - #{response.body}" unless response.code == "200"

      JSON.parse(response.body)
    end

    def build_body
      {
        model: "gpt-3.5-turbo",
        messages: history
      }
    end

    def system_message
      return nil if @system_prompt.nil?

      {
        role: "system",
        content: @system_prompt
      }
    end

    def add_history(role, message)
      @history << {
        role: role,
        content: message
      }
    end

    def history
      [system_message].concat(@history).compact
    end
  end
end
