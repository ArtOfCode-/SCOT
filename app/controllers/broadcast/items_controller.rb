class Broadcast::ItemsController < ApplicationController
  before_action :check_access
  before_action :set_item, except: [:index, :new, :create, :setup_generation, :generate_script, :need_translation]

  def index
    @items = conditional_filter Broadcast::Item.active, originated_at: params[:originated_at], broadcast_municipality_id: params[:municipality],
                                                        source: params[:source], id: params[:id]
    @items = @items.includes(:municipality).order(originated_at: :desc).paginate page: params[:page], per_page: 100
  end

  def new
    @item = Broadcast::Item.new
  end

  def create
    @item = Broadcast::Item.new item_params.merge(user: current_user)
    if @item.save
      flash[:success] = 'Entry submitted to broadcast list.'
      redirect_to added_broadcast_item_path(@item)
    else
      render :new
    end
  end

  def edit; end

  def update
    if @item.update item_params
      redirect_to added_broadcast_item_path(@item)
    else
      render :edit
    end
  end

  def added
    @panda = Rails.cache.fetch :panda, expires_in: 5.minutes do
      panda_req = HTTParty.get("https://api.giphy.com/v1/gifs/random?key=#{Settings.giphy_api_key}&tag=panda")
      if panda_req.code == 200
        JSON.parse(panda_req.body)['data']['image_url']
      end
    end
  end

  def need_translation
    @items = Broadcast::Item.active.where("translation IS NULL OR translation = ''").order(originated_at: :desc)
                            .paginate(page: params[:page], per_page: 100)
  end

  def add_translation; end

  def submit_translation
    if @item.update translation: params[:translation]
      redirect_to added_broadcast_item_path(@item, t: 0, tn: 1)
    else
      render :add_translation
    end
  end

  def setup_generation; end

  def generate_script
    @document = Broadcast::Item.generate_script(params.dup.permit(:name, :max_general, :max_muni, :min_origin).to_h)
  end

  def deprecate_item
    @item.update(deprecated: true)
    flash[:success] = 'Marked item as deprecated.'
    redirect_back fallback_location: broadcast_items_path
  end

  private

  def check_access
    require_any :developer, :admin, :broadcast, :miner
  end

  def item_params
    params.require(:broadcast_item).permit(:content, :originated_at, :broadcast_municipality_id, :translation, :source)
  end

  def set_item
    @item = Broadcast::Item.find params[:id]
  end

  def conditional_filter(col, **filters)
    cols = Broadcast::Item.columns.map { |c| [c.name.to_sym, c] }.to_h
    types = filters.keys.map { |k| [k, cols[k].sql_type_metadata.type] }.to_h
    filters.each do |k, v|
      next unless v.present?
      col = if [:string, :text].include? types[k]
              col.where("#{k} LIKE ?", "%#{v}%")
            else
              col.where(k => v)
            end
    end
    col
  end
end
