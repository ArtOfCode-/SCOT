class Broadcast::Item < ApplicationRecord
  belongs_to :municipality, class_name: 'Broadcast::Municipality', optional: true, foreign_key: 'broadcast_municipality_id'
  belongs_to :user, optional: true
  belongs_to :request, optional: true, class_name: 'Translation' # Translation request. .translation was already taken.

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

    {
      english: {
        general: general("english", general_items),
        municipalities: municipalities("english", municipal_items, params)
      },
      spanish: {
        general: general("spanish", general_items),
        municipalities: municipalities("spanish", municipal_items, params)
      }
    }
  end

  def self.save_script
    timestamp = DateTime.now.strftime('%H:00')
    datestamp = Date.today.strftime('%Y-%m-%d')
    name = "CRHQ Broadcast #{datestamp} #{timestamp}"
    params = { min_origin: 4.days.ago.iso8601, name: name }
    script = generate_script(params)

    unless Dir.exist? Rails.root.join('data')
      Dir.mkdir(Rails.root.join('data'))
    end
    File.write(Rails.root.join('data', "#{name}.yaml"), script.to_yaml)
  end

  private

  def self.general(language, items, document = [])
    header = case language
    when "english"
      "General Interest"
    when "spanish"
      "Noticias de Interés General"
    else
      "Could not generate header"
    end

    {
      header: header,
      items: items.map do |i|
        {
          id: i.id,
          originated_at: i.originated_at,
          body: language == "english" ? i.content : i.translation
        }
      end
    }
  end

  def self.municipalities(language, items, params, document = [])
    header = case language
    when "english"
      "Municipalities"
    when "spanish"
      "Municipios"
    else
      "Could not generate header"
    end

    {
      header: header,
      municipalities: items.map do |_id, municipality|
        {
          name: municipality[0].municipality.name,
          items: municipality.first(params[:max_muni].to_i).map do |i|
            {
              id: i.id,
              originated_at: i.originated_at,
              body: language == "english" ? i.content : i.translation
            }
          end
        }
      end
    }
  end
end
