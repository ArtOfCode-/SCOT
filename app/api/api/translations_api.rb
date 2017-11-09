module API
  class TranslationsAPI < API::Base
    prefix :translations

    resource :langs do
      get '/' do
        std_result Translations::Language.all
      end

      get 'source/:lang_id' do
        std_result Translation.where(source_lang_id: params[:lang_id])
      end

      get 'target/:lang_id' do
        std_result Translation.where(target_lang_id: params[:lang_id])
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

    get '/status/:status_id' do
      std_result Translation.where(status_id: params[:status_id])
    end
  end
end