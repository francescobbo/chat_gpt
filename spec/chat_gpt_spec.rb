# frozen_string_literal: true

RSpec.describe ChatGPT do
  it "has a version number" do
    expect(ChatGPT::VERSION).not_to be nil
  end
end
