unless Rails.env.production?
  Dotenv.require_keys(
    'SCHEMA_SEARCH_PATH',
    'ADMIN_NAME',
    'ADMIN_PASSWORD',
    'EMAIL_FROM',
    'EMAIL_RECIPIENTS'
  )
end
