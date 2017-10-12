class Broadcast::Item < ApplicationRecord
  belongs_to :municipality, class_name: 'Broadcast::Municipality', optional: true, foreign_key: 'broadcast_municipality_id'
  belongs_to :user, optional: true

  scope :active, -> { where(deprecated: false) }

  after_create do
    update(originated_at: created_at) unless originated_at.present?
  end

  def self.generate_script(params)
    document = []
    params[:min_origin] = params[:min_origin].present? ? params[:min_origin] : '1970-01-01T00:00:00'
    params[:max_general] = params[:max_general].present? ? params[:max_general] : 9999
    params[:max_muni] = params[:max_muni].present? ? params[:max_muni] : 9999

    general_items = Broadcast::Item.active.where('originated_at > ?', params[:min_origin]).where(municipality: nil).limit(params[:max_general])
                        .order(originated_at: :desc)
    municipal_items = Broadcast::Item.active.includes(:municipality).where('originated_at > ?', params[:min_origin]).where.not(municipality: nil)
                          .order(originated_at: :desc)
    municipal_items = municipal_items.group_by(&:broadcast_municipality_id)
                          .sort_by { |municipality_id, _r| Broadcast::Municipality.find(municipality_id).name }

    document << "<h1>#{params[:name]}</h1>"
    document << '<h2 id="english_broadcast">English Broadcast</h2>'

    document << '<h3 id="general_interest">General Interest</h3>'
    document << '<ul>'
    general_items.each do |i|
      document << "<li data-id='#{i.id}'>"
      document << "<span class='text-muted'>(ID #{i.id})</span>"
      document << "<strong>#{i.originated_at.strftime('%e %b')}</strong>: #{i.content.gsub("\n", '<br/>')}"
      document << '</li>'
    end
    document << '</ul>'

    document << '<h3 id="municipalities">Municipalities</h3>'
    municipal_items.each do |_id, municipality|
      next if municipality.empty?
      name = municipality[0].municipality.name
      document << "<h4 id='#{name.downcase.tr(' ', '_')}_eng'>#{name}</h4>"
      document << '<ul>'
      municipality.first(params[:max_muni].to_i).each do |i|
        document << "<li data-id='#{i.id}'>"
        document << "<span class='text-muted'>(ID #{i.id})</span>"
        document << "<strong>#{i.originated_at.strftime('%e %b')}</strong>: #{i.content.gsub("\n", '<br/>')}"
        document << '</li>'
      end
      document << '</ul>'
    end

    document << '<hr/>'

    document << '<h2 id="spanish_broadcast">Spanish Broadcast</h2>'

    document << '<h3 id="noticias_de_interés_general">Noticias de Interés General</h3>'
    document << '<ul>'
    general_items.each do |i|
      document << "<li data-id='#{i.id}'>"
      document << "<span class='text-muted'>(ID #{i.id})</span>"
      document << "<strong>#{i.originated_at.strftime('%e %b')}</strong>: #{i.translation.gsub("\n", '<br/>')}"
      document << '</li>'
    end
    document << '</ul>'

    document << '<h3 id="municipios">Municipios</h3>'
    municipal_items.each do |_id, municipality|
      next if municipality.empty?
      name = municipality[0].municipality.name
      document << "<h4 id='#{name.downcase.tr(' ', '_')}_spa'>#{name}</h4>"
      document << '<ul>'
      municipality.first(params[:max_muni].to_i).each do |i|
        document << "<li data-id='#{i.id}'>"
        document << "<span class='text-muted'>(ID #{i.id})</span>"
        document << "<strong>#{i.originated_at.strftime('%e %b')}</strong>: #{i.translation.gsub("\n", '<br/>')}"
        document << '</li>'
      end
      document << '</ul>'
    end
    document
  end

  def self.save_script
    timestamp = DateTime.now.strftime('%H:00')
    datestamp = Date.today.strftime('%Y-%m-%d')
    name = "CRHQ Broadcast #{datestamp} #{timestamp}"
    params = { min_origin: 4.days.ago.iso8601, name: name }
    script = generate_script(params).join("\n")

    unless Dir.exist? Rails.root.join('data')
      Dir.mkdir(Rails.root.join('data'))
    end
    File.write(Rails.root.join('data', "#{name}.html"), script)
  end
end
