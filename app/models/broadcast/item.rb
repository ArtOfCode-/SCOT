class Broadcast::Item < ApplicationRecord
  belongs_to :municipality, class_name: 'Broadcast::Municipality', optional: true, foreign_key: 'broadcast_municipality_id'
  belongs_to :user, optional: true
  belongs_to :status, class_name: 'Broadcast::Status', foreign_key: 'status_id', optional: true
  has_many :translations, class_name: 'Translation', foreign_key: 'broadcast_item_id'

  scope :active, -> { where(deprecated: false) }
  scope :with_assoc, -> { includes(:municipality, :user, :status, translations: [:source_lang, :target_lang]) }

  after_create do
    changes = {}
    changes[:originated_at] = created_at unless originated_at.present?
    changes[:status] = Broadcast::Status['Pending Review']
    update(**changes)
  end

  def self.generate_script(params)
    params[:min_origin] = params[:min_origin].present? ? params[:min_origin] : '1970-01-01T00:00:00'
    params[:max_general] = params[:max_general].present? ? params[:max_general] : 9999
    params[:max_muni] = params[:max_muni].present? ? params[:max_muni] : 9999

    all_items = Broadcast::Item.active.includes(:municipality).includes(translations: [:source_lang, :target_lang]).order(originated_at: :desc)

    top_items = all_items.where(top: true)
    bottom_items = all_items.where(bottom: true)
    tb_ids = top_items.map(&:id) + bottom_items.map(&:id)

    general_items = all_items.where('originated_at > ?', params[:min_origin]).where(municipality: nil).where.not(id: tb_ids)
                             .limit(params[:max_general])

    municipal_items = all_items.where('originated_at > ?', params[:min_origin]).where.not(municipality: nil).where.not(id: tb_ids)
    municipal_items = municipal_items.group_by(&:municipality)
                                     .sort_by { |municipality, _i| municipality.name }

    en_us = Translations::Language['en-US']
    es_pr = Translations::Language['es-PR']

    {
      english: {
        top:            top(en_us, top_items),
        general:        general(en_us, general_items),
        municipalities: municipalities(en_us, municipal_items, params),
        bottom:         bottom(en_us, bottom_items)
      },
      spanish: {
        top:            top(es_pr, top_items),
        general:        general(es_pr, general_items),
        municipalities: municipalities(es_pr, municipal_items, params),
        bottom:         bottom(es_pr, bottom_items)
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

  def self.general(language, items, _document = [])
    header = case language
             when Translations::Language['en-US']
               'General Interest'
             when Translations::Language['es-PR']
               'Noticias de Interés General'
             else
               'Could not generate header'
             end

    {
      header: header,
      items: items.map do |i|
        translation = i.translations.first
        {
          id: i.id,
          originated_at: i.originated_at,
          body: translation.source_lang == language ? translation.content : translation.final
        }
      end
    }
  end

  def self.top(language, items, _document = [])
    header = case language
             when Translations::Language['en-US']
               'Opening'
             when Translations::Language['es-PR']
               'Saludo'
             else
               'Could not generate header'
             end

    {
      header: header,
      items: items.map do |i|
        translation = i.translations.first
        {
          id: i.id,
          originated_at: i.originated_at,
          body: translation.source_lang == language ? translation.content : translation.final
        }
      end
    }
  end

  def self.bottom(language, items, _document = [])
    header = case language
             when Translations::Language['en-US']
               'Closing'
             when Translations::Language['es-PR']
               'Despedida'
             else
               'Could not generate header'
             end

    {
      header: header,
      items: items.map do |i|
        translation = i.translations.first
        {
          id: i.id,
          originated_at: i.originated_at,
          body: translation.source_lang == language ? translation.content : translation.final
        }
      end
    }
  end

  def self.municipalities(language, items, params, _document = [])
    header = case language
             when Translations::Language['en-US']
               'Municipalities'
             when Translations::Language['es-PR']
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
            translation = i.translations.first
            {
              id: i.id,
              originated_at: i.originated_at,
              body: translation.source_lang == language ? translation.content : translation.final
            }
          end
        }
      end
    }
  end

  def self.search(term)
    Broadcast::Item.joins(:translations).match_search(term, translations: [:content, :final])
  end
end
