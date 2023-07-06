require 'csv'
require 'interactor'

class WriteArticleListFile
  include Interactor

  def call
    header = %w[id link title year category file]

    records = context.article_list
    file_mode = 'a'

    unless File.exist?(context.output_file)
      file_mode = 'w'
      records.insert(0, header)
    end

    CSV.open(context.output_file, file_mode) do |csv|
      # Write the data rows to the CSV file
      records.each do |row|
        csv << row
      end
    end
  end
end
