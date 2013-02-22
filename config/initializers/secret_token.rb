secret_token_file = File.join(Rails.root, "config", "secret_token.yml")

if File.exists?(secret_token_file)
  secret_token = YAML.load_file(secret_token_file)[:secret_token]
else
  secret_token = SecureRandom.hex(64)
  File.open(secret_token_file, 'w') do |file|
    file.write({:secret_token => secret_token}.to_yaml)
  end
end

Vizir::Application.config.secret_token = secret_token
