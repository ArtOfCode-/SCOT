class Broadcast::MunicipalitiesController < ApplicationController
  before_action :check_access

  def last_updates
    @updates = Broadcast::Municipality.joins(:items).group('broadcast_municipalities.id')
                                      .select('broadcast_municipalities.name, broadcast_municipalities.id, ' \
                                              'MAX(broadcast_items.originated_at) AS last_update')
                                      .order('MAX(broadcast_items.originated_at) ASC')
  end

  private

  def check_access
    require_any :developer, :admin, :broadcast, :miner
  end
end
