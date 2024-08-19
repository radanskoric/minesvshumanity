class RodauthApp < Rodauth::Rails::App
  # primary configuration
  configure RodauthMain

  # secondary configuration
  # configure RodauthAdmin, :admin

  route do |r|
    rodauth.load_memory # autologin remembered users

    r.rodauth # route rodauth requests

    # ==> Authenticating requests
    # Call `rodauth.require_account` for requests that you want to
    # require authentication for. Either here or in the Rails controller.
    #
    # # For example: authenticate /dashboard/* requests
    # if r.path.start_with?("/games/new")
    #   rodauth.require_account
    # end
  end
end
