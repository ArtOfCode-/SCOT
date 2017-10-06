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
    @item = Broadcast::Item.new item_params
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

  def added; end

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
    @document = []
    params[:min_origin] = params[:min_origin].present? ? params[:min_origin] : '1970-01-01T00:00:00'
    params[:max_general] = params[:max_general].present? ? params[:max_general] : 9999
    params[:max_muni] = params[:max_muni].present? ? params[:max_muni] : 9999

    general_items = Broadcast::Item.active.where('originated_at > ?', params[:min_origin]).where(municipality: nil).limit(params[:max_general])
                                   .order(originated_at: :desc)
    municipal_items = Broadcast::Item.active.includes(:municipality).where('originated_at > ?', params[:min_origin]).where.not(municipality: nil)
                                     .order(originated_at: :desc)
    municipal_items = municipal_items.group_by(&:broadcast_municipality_id)
                                     .sort_by { |municipality_id, _r| Broadcast::Municipality.find(municipality_id).name }

    @document << "<h1>#{params[:name]}</h1>"
    @document << '<h2 id="english_broadcast">English Broadcast</h2>'

    @document << '<h3 id="general_interest">General Interest</h3>'
    @document << '<ul>'
    general_items.each do |i|
      @document << "<li data-id='#{i.id}'>"
      @document << "<span class='text-muted'>(ID #{i.id})</span>"
      @document << "<strong>#{i.originated_at.strftime('%e %b')}</strong>: #{i.content.gsub("\n", '<br/>')}"
      @document << '</li>'
    end
    @document << '</ul>'

    @document << '<h3 id="municipalities">Municipalities</h3>'
    municipal_items.each do |_id, municipality|
      next if municipality.empty?
      name = municipality[0].municipality.name
      @document << "<h4 id='#{name.downcase.tr(' ', '_')}_eng'>#{name}</h4>"
      @document << '<ul>'
      municipality.first(params[:max_muni]).each do |i|
        @document << "<li data-id='#{i.id}'>"
        @document << "<span class='text-muted'>(ID #{i.id})</span>"
        @document << "<strong>#{i.originated_at.strftime('%e %b')}</strong>: #{i.content.gsub("\n", '<br/>')}"
        @document << '</li>'
      end
      @document << '</ul>'
    end

    @document << '<hr/>'

    @document << '<h2 id="spanish_broadcast">Spanish Broadcast</h2>'

    @document << '<h3 id="noticias_de_interés_general">Noticias de Interés General</h3>'
    @document << '<ul>'
    general_items.each do |i|
      @document << "<li data-id='#{i.id}'>"
      @document << "<span class='text-muted'>(ID #{i.id})</span>"
      @document << "<strong>#{i.originated_at.strftime('%e %b')}</strong>: #{i.translation.gsub("\n", '<br/>')}"
      @document << '</li>'
    end
    @document << '</ul>'

    @document << '<h3 id="municipios">Municipios</h3>'
    municipal_items.each do |_id, municipality|
      next if municipality.empty?
      name = municipality[0].municipality.name
      @document << "<h4 id='#{name.downcase.tr(' ', '_')}_spa'>#{name}</h4>"
      @document << '<ul>'
      municipality.first(params[:max_muni]).each do |i|
        @document << "<li data-id='#{i.id}'>"
        @document << "<span class='text-muted'>(ID #{i.id})</span>"
        @document << "<strong>#{i.originated_at.strftime('%e %b')}</strong>: #{i.translation.gsub("\n", '<br/>')}"
        @document << '</li>'
      end
      @document << '</ul>'
    end
  end

  def deprecate_item
    @item.update(deprecated: true)
    flash[:success] = 'Marked item as deprecated.'
    redirect_to broadcast_items_path
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
