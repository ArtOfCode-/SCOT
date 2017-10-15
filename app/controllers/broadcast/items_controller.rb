class Broadcast::ItemsController < ApplicationController
  before_action :check_access, except: [:scripts, :view_script]
  before_action :set_item, except: [:index, :new, :create, :setup_generation, :generate_script, :need_translation, :scripts, :view_script]

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
      if @item.translation.empty?
        urlopts = Rails.configuration.action_mailer.default_url_options
        url = Rails.application.routes.url_helpers.translate_broadcast_item_url(@item, host: urlopts[:host], port: urlopts[:port])
        now = DateTime.now.utc
        if now.hour >= 0 && now.hour < 14
          now = now.change(hour: 14)
        elsif now.hour >= 14
          now = (now + 1.day).change(hour: 0)
        end
        from = Translations::Language['en-US']
        to = Translations::Language['es-PR']
        priority = Translations::Priority['Semi-Urgent']
        request = Translation.create(content: url, source_lang: from, target_lang: to, deliver_to: 'SCOT',
                                     due: now, requester: current_user, priority: priority)
        @item.update(request: request)
      end
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
      JSON.parse(panda_req.body)['data']['image_url'] if panda_req.code == 200
    end
  end

  def need_translation
    @items = Broadcast::Item.active.where("translation IS NULL OR translation = ''").order(originated_at: :desc)
                            .paginate(page: params[:page], per_page: 100)
  end

  def add_translation; end

  def submit_translation
    if @item.update translation: params[:translation]
      if @item.request.present?
        status = Translations::Status['Completed']
        @item.request.update(status: status, assignee: current_user)
      end
      redirect_to added_broadcast_item_path(@item, t: 0, tn: 1)
    else
      render :add_translation
    end
  end

  def setup_generation; end

  def generate_script
    @broadcasts = Broadcast::Item.generate_script(params.dup.permit(:name, :max_general, :max_muni, :min_origin).to_h)
  end

  def deprecate_item
    @item.update(deprecated: true)
    flash[:success] = 'Marked item as deprecated.'
    redirect_back fallback_location: broadcast_items_path
  end

  def scripts
    @files = Dir[Rails.root.join('data', '*.yml')].map { |f| [File.basename(f, '.yml'), 'yml'] } + Dir[Rails.root.join('data', '*.html')].map { |f| [File.basename(f, '.html'), 'html'] }
  end

  def view_script
    if params[:format] == 'html'
      @document = File.read(Rails.root.join('data', "#{params[:file].tr('/', '')}.html")).split("\n")
      render :generate_html_script
    else
      @broadcasts = YAML.load_file(Rails.root.join('data', "#{params[:file].tr('/', '')}.yml"))
      render :generate_script, formats: [:html, :erb]
    end
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
