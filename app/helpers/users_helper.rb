module UsersHelper
  def users_index_return_to(page:, query:)
    url_params = {}
    url_params[:page] = page if page.present?
    url_params[:q] = query if query.present?
    users_path(**url_params)
  end

  def safe_users_return_path(return_to)
    raw = return_to.to_s
    return users_path if raw.blank? || !raw.start_with?("/")

    uri = URI.parse(raw)
    users_index_path = URI.parse(users_path).path
    return users_path if uri.scheme.present? || uri.host.present? || uri.path != users_index_path

    query_params = Rack::Utils.parse_nested_query(uri.query.to_s).slice("page", "q")
    users_index_return_to(page: query_params["page"], query: query_params["q"])
  rescue URI::InvalidURIError
    users_path
  end
end
