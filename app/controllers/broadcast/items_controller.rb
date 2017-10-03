class Broadcast::ItemsController < ApplicationController
  before_action :check_access
  before_action :set_item, except: [:new, :create, :added]

  def new
    @item = Broadcast::Item.new
  end

  def create
    @item = Broadcast::Item.new item_params
    if @item.save
      redirect_to added_broadcast_item_path(@item)
    else
      render :new
    end
  end

  def added; end

  def add_translation; end

  def submit_translation
    if @item.update translation: params[:translation]
      redirect_to added_broadcast_item_path(@item, t: 0)
    else
      render :add_translation
    end
  end

  private

  def check_access
    require_any :developer, :admin, :broadcast
  end

  def item_params
    params.require(:broadcast_item).permit(:content, :originated_at, :broadcast_municipality_id, :translation, :source)
  end

  def set_item
    @item = Broadcast::Item.find params[:id]
  end
end
