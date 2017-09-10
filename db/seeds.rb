# DO NOT ADD SEED DATA TO THIS FILE.
# Instead, create (or append to) a YAML file in the db/seeds directory; records will be created from
# those files by this script.

Rails.application.eager_load!

Dir.glob(Rails.root.join('db/seeds/*.yml')).each do |f|
  basename = File.basename f, '.yml'
  type = basename.singularize.classify.constantize
  data = YAML.load_file f
  type.create data
end
