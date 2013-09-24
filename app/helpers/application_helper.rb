module ApplicationHelper

  def link_to_login
    link_to('Login', new_user_session_path, class: 'btn')
  end

  def link_to_logout
    link_to('Logout', destroy_user_session_path, :method => :delete, class: 'btn')
  end

  def link_to_nav(label, path)
    link = link_to_unless_current(label, path) do
      link_to label, '#', class: 'active'
    end
    args = {}
    args[:class] = 'active' if current_page?(path)
    content_tag('li', link, args )
  end

end
