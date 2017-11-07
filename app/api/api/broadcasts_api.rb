module API
  class BroadcastsAPI < API::Base
    prefix :broadcasts

    resource :items do
      get '/' do
        std_result Broadcast::Item.active
      end

      get '/deprecated' do
        std_result Broadcast::Item.where(deprecated: true)
      end

      get '/search' do
        items = Broadcast::Item.all
        items = items.where(broadcast_municipality_id: params[:municipality_id]) if params[:municipality_id].present?
        items = items.search(params[:search_term]) if params[:search_term].present?
        std_result items
      end

      get '/review' do
        std_result Broadcast::Item.active.where(status: Broadcast::Status['Pending Review'])
      end
    end

    resource :municipalities do
      get '/' do
        std_result Broadcast::Municipality.all
      end

      get '/updates' do
        std_result Broadcast::Municipality.joins(:items).group('broadcast_municipalities.id')
                                          .select('broadcast_municipalities.name, broadcast_municipalities.id, ' \
                                              'MAX(broadcast_items.originated_at) AS last_update')
                                          .order('MAX(broadcast_items.originated_at) ASC'),
                   countable: false
      end
    end

    resource :statuses do
      get '/' do
        std_result Broadcast::Status.all
      end
    end
  end
end