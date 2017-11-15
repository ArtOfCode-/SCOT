class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.match_search(term, **cols)
    cols = cols.map do |k, v|
      if v.is_a?(Array)
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

  def self.status_transaction
    status = true
    ActiveRecord::Base.transaction do
      begin
        yield
      rescue StandardError
        status = false
        raise ActiveRecord::Rollback, 'A query raised an error.'
      end
    end
    status
  end

  def self.mass_insert(cols, values)
    cols = cols.map { |c| sanitize_name c }
    values = values.map do |v|
      wrapper = "(#{('?, ' * cols.size).chomp(', ')})"
      ActiveRecord::Base.send(:sanitize_sql_array, [wrapper, *v])
    end
    stmt = "INSERT INTO #{sanitize_name self.table_name} (#{cols.join(', ')}) VALUES #{values.join(', ')};"
    ActiveRecord::Base.connection.execute stmt
  end

  def match_search(term, **cols)
    match_search(term, **cols)
  end
end
