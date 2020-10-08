# Rails template



**Security headers**

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


** Require per-form CSRF tokens**
* Removed `csrf_meta_tags` from app/views/layouts/application.html.erb
  * These tags create and pass a global CSRF (rather than per-form) into the page.
* Override `compare_with_real_token` and `compare_with_global_token` to always return false, where the former is a legacy global token, and the latter is the current global token, neither of which we want to support -- only per-form tokens.

**Use Fetch Metadata to protect against cross-origin attacks**
* FetchMetadataProcessor middleware implements the guidance on https://web.dev/fetch-metadata/, but made slightly more restrictive by removing `same-site` from the list of allowed Sec-Fetch-Site values. If your subdomains are 'trusted' and you want to allow cross site requests from them, add `same-site` back to `ALLOWED_SEC_FETCH_SITES`.
* Disallowed cross site requests will return a not-very-user-friendly 400 error. You likely want to write your own logic here  to log any errors to detect any breakage from intended cross-origin requests.

**Use Cross-Origin-Opener-Policy to prevent cross-origin info leaks**
* The AddCrossOriginOpenerPolicy middleware sets the `Cross-Origin-Opener-Policy` header to `same-origin` to prevent various types of cross-domain attacks relying on window references.
* Set `response.headers["Cross-Origin-Opener-Policy"] = "setfromcontroller"` to opt out.
