module API
  class Broadcasts < API::Base
    prefix :broadcasts

    resource :items do
      desc 'Lists active broadcast items in reverse chronological order.'
      get '/' do
        std_result Broadcast::Item.active
      end

      desc 'Lists broadcast items that have been removed from scripts manually.'
      get '/deprecated' do
        std_result Broadcast::Item.where(deprecated: true)
      end

      desc 'Searches through active broadcast items based on parameters you specify.'
      params do
        requires :key, type: String, desc: 'Your API key.'
        optional :page, type: Integer, desc: 'The page of results to return.'
        optional :per_page, type: Integer, desc: 'Number of results to return per page.'

        optional :municipality_id, type: Integer, desc: 'The ID of a municipality to limit your search to.'
        optional :search_term, type: String, desc: 'A text string to search for in the content of broadcast items.'
      end
      get '/search' do
        items = Broadcast::Item.all
        items = items.where(broadcast_municipality_id: params[:municipality_id]) if params[:municipality_id].present?
        items = items.search(params[:search_term]) if params[:search_term].present?
        std_result items
      end
    end
  end
end