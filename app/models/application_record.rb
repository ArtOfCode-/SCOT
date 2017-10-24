class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.match_search(term, **cols)
    cols = cols.map do |k, v|
      if v.kind_of?(Array)
        v.map { |vv| "#{sanitize_name k}.#{sanitize_name vv}" }.join(', ')
      else
        "#{sanitize_name k}.#{sanitize_name v}"
      end
    end.join(', ')

    sanitized = ActiveRecord::Base.send(:sanitize_sql_array, ["MATCH (#{cols}) AGAINST (? IN BOOLEAN MODE)", term])
    where(sanitized)
  end

  def self.sanitize_name(name)
    name.to_s.delete('`').insert(0, '`').insert(-1, '`')
  end

  def match_search(term, **cols)
    self.match_search(term, **cols)
  end
end
