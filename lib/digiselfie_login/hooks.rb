module DigiselfieLogin
  class Hooks < Redmine::Hook::ViewListener
    def view_account_login_bottom(context = {})
      context[:controller].send(:render_to_string, {
        :partial => "hooks/digiselfie_login_view_account_login_bottom",
        :locals => context})
    end
  end
end
