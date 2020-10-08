if Rails.env.production?
  Rails.application.config.session_store :active_record_store, :key => '__Host-example-session'
else
  Rails.application.config.session_store :active_record_store, :key => 'example-session'
end

ActiveRecord::SessionStore::Session.serializer = :json
