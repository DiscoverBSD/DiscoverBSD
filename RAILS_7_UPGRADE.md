# Rails 7.2 Upgrade Notes

This document summarizes the upgrade from Rails 6.1.7.10 to Rails 7.2.3.

## Summary

The application has been successfully upgraded to Rails 7.2.3, the latest stable version of Rails.

## Major Changes

### 1. Rails Version
- **Before**: Rails 6.1.7.10
- **After**: Rails 7.2.3

### 2. Dependency Updates

#### OmniAuth
- **Before**: OmniAuth 1.9.x
- **After**: OmniAuth 2.1.4
- **Breaking Change**: OmniAuth 2.x requires POST requests for authentication instead of GET
- **Fix Applied**: Updated authentication button in `app/views/posts/new.html.erb` to use `button_to` with `method: :post`
- **New Dependency**: Added `omniauth-rails_csrf_protection` gem for CSRF protection

#### Spring Preloader
- **Removed**: Spring and spring-watcher-listen gems
- **Reason**: Spring is no longer maintained and incompatible with Rails 7.2
- **Impact**: Development server may take slightly longer to start, but this is negligible with modern hardware

#### Other Dependencies
- Updated jbuilder to ~> 2.11
- Updated bootsnap constraints
- Removed concurrent-ruby pin (issue fixed in Rails 7.x)
- Updated omniauth-github to 2.0.1

### 3. Configuration Changes

#### application.rb
- Changed `config.load_defaults` from `6.0` to `7.0`

#### New Initializer
- Added `config/initializers/new_framework_defaults_7_2.rb`
- This file contains commented-out Rails 7.2 defaults
- Uncomment settings gradually to adopt new Rails 7.2 behaviors

### 4. Ruby Version
- Updated Dockerfile from Ruby 3.3.5 to Ruby 3.4.7
- Application requires Ruby 3.4.7 as specified in `.ruby-version`

## Testing

The upgrade has been verified to:
- ✅ Load the Rails application successfully
- ✅ Load all routes correctly
- ✅ Load models without errors
- ✅ Pass security scanning (CodeQL)
- ✅ No code review issues

## What to Test

Before deploying to production, please test:

1. **Authentication Flow**
   - Sign in via GitHub OAuth should work with the new POST-based flow
   - Session management should work as expected

2. **Background Jobs**
   - Delayed Job workers should process jobs correctly
   - Check for any deprecation warnings in job processing

3. **Database Operations**
   - All CRUD operations should work
   - Check for any deprecation warnings

4. **Asset Pipeline**
   - Webpacker compilation should work
   - SCSS compilation should work
   - JavaScript should load correctly

## Potential Issues to Watch

1. **Platform Deprecations**: There are deprecation warnings for Windows platforms in the Gemfile. These can be ignored if you're not deploying on Windows.

2. **Fiddle Warning**: Spring was using `fiddle` which will be removed from Ruby 3.5.0. Since we removed Spring, this warning should not appear in production.

3. **New Framework Defaults**: The new defaults in `new_framework_defaults_7_2.rb` are commented out. Consider enabling them one by one after testing:
   - Active Job transaction commit behavior
   - Active Storage WebP support
   - Migration timestamp validation
   - PostgreSQL date decoding
   - YJIT (performance improvement)

## Resources

- [Rails 7.0 Upgrade Guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-6-1-to-rails-7-0)
- [Rails 7.2 Release Notes](https://guides.rubyonrails.org/7_2_release_notes.html)
- [OmniAuth 2.0 Upgrade Guide](https://github.com/omniauth/omniauth/wiki/Upgrading-to-2.0)

## Next Steps

1. Run the full test suite: `bundle exec rails test`
2. Test in a staging environment
3. Enable Rails 7.2 defaults gradually
4. Monitor for deprecation warnings
5. Update to `config.load_defaults 7.2` once all defaults are adopted
