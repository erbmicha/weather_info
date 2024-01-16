[
  { env: 'VISUAL_CROSSING_API_KEY', cred: 'visual_crossing_api_key' },
].each do |env_hash|
  env_value = ENV.fetch(env_hash[:env], Rails.application.credentials[env_hash[:cred].to_sym])
  next if env_value.present?

  raise <<~MSG
    Missing environment variable: #{env_hash[:env]} or Rails credential: #{env_hash[:cred]}.

    Ask a teammate for the appropriate value.
  MSG
end
