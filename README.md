# Rails template

A fresh Rails application from `rails new` containing common changes I tend to make on new projects.

**Security headers**

Applies a strong default set of security headers using the [secure_headers](https://github.com/github/secure_headers) gem.

```ruby
# config/initializers/secure_headers.rb

SecureHeaders::Configuration.default do |config|
  config.referrer_policy = "strict-origin-when-cross-origin"
  config.hsts = "max-age=#{20.years.to_i}; includeSubdomains"
  config.cookies = {
    secure: true,
    httponly: true,
    samesite: {
      strict: true
    }
  }
  config.csp = {
    default_src: %w('none'),
    base_uri: %w('self'),
    block_all_mixed_content: true,
    child_src: %w('self'),
    connect_src: %w('self'),
    font_src: %w('self'),
    form_action: %w('self'),
    frame_ancestors: %w('none'),
    img_src: %w('self'),
    manifest_src: %w('self'),
    object_src: %w('none'),
    script_src: %w('self'),
    style_src: %w('self')
  }
end
```

Of note:
* [HSTS](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security)
* Cookies will default to http-only, secure, and a samesite value of `strict`.
  - You'll likely want to loosen these for certain cookies, so see [`cookies.md`](https://github.com/github/secure_headers/blob/main/docs/cookies.md) for how to do so.
* A [Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP) setting a default-src of `'none'` and disallowing inline javascript.
  - It's preferred to serve javascript assets from a CDN you control, and set it in the script-src directive and remove `'self'`. This way your application (which can serve all sorts of dynamic content) is not allowed as a script source, and cannot be leveraged for XSS in the event of a content injection vulnerability. Nor will your application be allowed to use unsafe patterns like [JSONP](https://stackoverflow.com/questions/2067472/what-is-jsonp-and-why-was-it-created).

**Bcrypt password hashing**
* Uses Active Model's has_secure_password to use Bcrypt password hashing on User passwords.
* Uses the default cost parameter of 12.

**User sessions with Active Record Session Store**
* Server-sided session storage using [Active Record Session Store](https://github.com/rails/activerecord-session_store).
* Uses `__Host` cookies to ensure the session cookie cannot be clobbered through [cookie-tossing](https://github.blog/2013-04-09-yummy-cookies-across-domains/) style issues.

```ruby
# config/initializers/session_store.rb

if Rails.env.production?
  Rails.application.config.session_store :active_record_store, :key => '__Host-example-session'
else
  Rails.application.config.session_store :active_record_store, :key => 'example-session'
end

ActiveRecord::SessionStore::Session.serializer = :json
```

**Require per-form CSRF tokens**
* Removed `csrf_meta_tags` from `app/views/layouts/application.html.erb`
  * These tags create and pass a global CSRF (rather than per-form) into the page.
* Override `compare_with_real_token` and `compare_with_global_token` to always return false during CSRF enforcement logic, where the former is a legacy global token, and the latter is the current global token, neither of which we want to support -- only per-form tokens.

**Use Fetch Metadata to protect against cross-origin attacks**
* FetchMetadataProcessor [middleware](./lib/middleware/fetch_metadata_processor.rb) implements the guidance on https://web.dev/fetch-metadata/, but made slightly more restrictive by removing `same-site` from the list of allowed Sec-Fetch-Site values. If your subdomains are 'trusted' and you want to allow cross site requests from them, add `same-site` back to `ALLOWED_SEC_FETCH_SITES`.
* Disallowed cross site requests will return a not-very-user-friendly 400 error. You likely want to write your own logic here  to log any errors to detect any breakage from intended cross-origin requests.

**Use Cross-Origin-Opener-Policy to prevent cross-origin info leaks**
* AddCrossOriginOpenerPolicy [middleware](lib/middleware/add_cross_origin_opener_policy.rb) sets the `Cross-Origin-Opener-Policy` header to `same-origin` to prevent various types of cross-domain attacks relying on window references.
* Set `response.headers["Cross-Origin-Opener-Policy"]` to change that header's value where needed.
