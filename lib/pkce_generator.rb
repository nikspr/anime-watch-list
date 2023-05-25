require 'securerandom'
require 'base64'
require 'digest'

def generate_code_verifier
  verifier = SecureRandom.urlsafe_base64(64).gsub(/[^A-Za-z0-9\-._~]/, '')
  verifier[0...128] # Ensure the verifier length is between 43 and 128 characters
end

def generate_code_challenge(verifier)
  base64_url_encoded_sha256 = Base64.urlsafe_encode64(Digest::SHA256.digest(verifier)).gsub(/[^A-Za-z0-9\-._~]/, '')
  base64_url_encoded_sha256[0...128] # Ensure the challenge length is between 43 and 128 charactersend
end
