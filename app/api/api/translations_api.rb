module API
  class TranslationsAPI < API::Base
    prefix :translations

    resource :languages do
      get '/' do
        std_result Translations::Language.all
      end
    end

    resource :priorities do
      get '/' do
        std_result Translations::Priority.all
      end
    end

    resource :statuses do
      get '/' do
        std_result Translations::Status.all
      end
    end

    get '/' do
      std_result Translation.all
    end

    get '/item/:item_id' do
      std_result Translation.where(broadcast_item_id: params[:item_id])
    end
  end
end