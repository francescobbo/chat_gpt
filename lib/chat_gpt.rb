# frozen_string_literal: true

require_relative "chat_gpt/client"
require_relative "chat_gpt/version"
require "net/http"
require "json"

# The main module for the ChatGPT gem
module ChatGPT
  class Error < StandardError; end
end
