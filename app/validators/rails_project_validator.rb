class RailsProjectValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add attribute, "must be path to Rails project w/ spec folder" if !File.directory?(value) || !Dir.entries(value).include?('spec')
  end
end
  