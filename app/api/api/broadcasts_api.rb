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

      params do
        requires :key, type: String
        requires :token, type: String

        optional :content, type: String
        optional :translation, type: String
        optional :originated_at, type: DateTime
        optional :broadcast_municipality_id, type: Integer
        optional :source, type: String
        optional :top, type: Boolean
        optional :bottom, type: Boolean
        optional :notes, type: String
      end
      post '/new' do
        authenticate_user! && role(:broadcast, :miner)
        item_params = params.except(:key, :token, :content, :translation)

        @item = Broadcast::Item.new item_params.merge(user: current_user)
        if !params[:content].nil? || !params[:translation].nil?
          now = DateTime.now.utc
          if now.hour >= 0 && now.hour < 14
            now = now.change(hour: 14)
          elsif now.hour >= 14
            now = (now + 1.day).change(hour: 0)
          end
          if !params[:translation].present?
            from = Translations::Language['en-US']
            to = Translations::Language['es-PR']
            content = params[:content]
          elsif !params[:content].present?
            from = Translations::Language['es-PR']
            to = Translations::Language['en-US']
            content = params[:translation]
          else
            from = Translations::Language['en-US']
            to = Translations::Language['es-PR']
            content = params[:content]
            final = params[:translation]
            status = Translations::Status['Completed']
          end

          success = ApplicationRecord.status_transaction do
            @item.save
            @item.translations.create(content: content, source_lang: from, target_lang: to, deliver_to: 'SCOT', due: now,
                                      requester: current_user, priority: Translations::Priority['Next Broadcast'],
                                      final: final, status: status)
          end

          if success
            std_result @item
          else
            error!({name: 'save_failed', detail: 'Creation transaction failed'}, 500)
          end
        else
          error!({name: 'missing_data', detail: 'Either content or translation is required'}, 400)
        end
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