module API
  class Base < Grape::API
    version 'v1', using: :path
    prefix :api
    format :json

    helpers do
      def current_user
        @current_user ||= @token.user
      end

      def authenticate_app!
        @key = APIKey.find_by key: params[:key]
        error!({ name: 'missing_key', detail: 'No key was provided or the provided key is invalid.' }, 403) unless @key.present?
      end

      def authenticate_user!
        @token = @key.api_tokens.find_by token: params[:token]
        error!({ name: 'missing_token', detail: 'No token was provided or the provided token is invalid.' }, 401) unless @token.present?
      end

      def authenticate_full!
        authenticate_app!
        authenticate_user!
      end

      def role(*names)
        return if current_user.has_any_role?(*names)
        error!({ name: 'unauthorized', detail: 'The authenticated user does not have the required permissions for this action.' }, 403)
      end
    end
  end
end