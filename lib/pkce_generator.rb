# frozen_string_literal: true

require 'securerandom'
require 'base64'
require 'digest'

def generate_code_verifier
  verifier = SecureRandom.urlsafe_base64(64).gsub(/[^A-Za-z0-9\-._~]/, '')
  verifier[0...128] # Ensure the verifier length is between 43 and 128 characters
end
