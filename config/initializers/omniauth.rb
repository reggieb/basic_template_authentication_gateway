Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :google_oauth2,
    '984880812821-e6hhe5jg3er30454qbkhj87i5ucp8ih3.apps.googleusercontent.com',
    'ls_WMFTFjordZzr_dNLUondg',
    {
      :scope => "userinfo.email, userinfo.profile"
    }
  )
end
