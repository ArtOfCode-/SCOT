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

    all_items = Broadcast::Item.active.includes(:municipality).where('originated_at > ?', params[:min_origin]).order(originated_at: :desc)

    top_items = all_items.where(top: true)
    bottom_items = all_items.where(bottom: true)

    general_items = all_items.where(municipality: nil).limit(params[:max_general]) - top_items - bottom_items

    municipal_items = all_items.where.not(municipality: nil) - top_items - bottom_items
    municipal_items = municipal_items.group_by(&:broadcast_municipality_id)
                                     .sort_by { |municipality_id, _r| Broadcast::Municipality.find(municipality_id).name }

    {
      english: {
        top: top('english', top_items),
        general: general('english', general_items),
        municipalities: municipalities('english', municipal_items, params),
        bottom: bottom('english', bottom_items)
      },
      spanish: {
        top: top('spanish', top_items),
        general: general('spanish', general_items),
        municipalities: municipalities('spanish', municipal_items, params),
        bottom: bottom('spanish', bottom_items)
      }
    }
  end

  def self.save_script
    timestamp = DateTime.now.strftime('%H:00')
    datestamp = Date.today.strftime('%Y-%m-%d')
    name = "CRHQ Broadcast #{datestamp} #{timestamp}"
    params = { min_origin: 4.days.ago.iso8601, name: name }
    script = generate_script(params)

    Dir.mkdir(Rails.root.join('data')) unless Dir.exist? Rails.root.join('data')
    File.write(Rails.root.join('data', "#{name}.yml"), script.to_yaml)
  end

  private

  def self.general(language, items, _document = [])
    header = case language
             when 'english'
               'General Interest'
             when 'spanish'
               'Noticias de Interés General'
             else
               'Could not generate header'
    end

    {
      header: header,
      items: items.map do |i|
        {
          id: i.id,
          originated_at: i.originated_at,
          body: language == 'english' ? i.content : i.translation
        }
      end
    }
  end

  def self.top(language, items, _document = [])
    header = case language
             when 'english'
               'Opening Announcements'
             when 'spanish'
               'Declaraciones Iniciales'
             else
               'Could not generate header'
    end

    {
      header: header,
      items: items.map do |i|
        {
          id: i.id,
          originated_at: i.originated_at,
          body: language == 'english' ? i.content : i.translation
        }
      end
    }
  end

  def self.bottom(language, items, _document = [])
    header = case language
             when 'english'
               'Closing Announcements'
             when 'spanish'
               'Declaraciones Concluyentes'
             else
               'Could not generate header'
    end

    {
      header: header,
      items: items.map do |i|
        {
          id: i.id,
          originated_at: i.originated_at,
          body: language == 'english' ? i.content : i.translation
        }
      end
    }
  end

  def self.municipalities(language, items, params, _document = [])
    header = case language
             when 'english'
               'Municipalities'
             when 'spanish'
               'Municipios'
             else
               'Could not generate header'
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
              body: language == 'english' ? i.content : i.translation
            }
          end
        }
      end
    }
  end
end
