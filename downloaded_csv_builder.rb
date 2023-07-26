require 'pdf-reader'
require 'csv'
require_relative 'article'
require_relative 'write_article_list_file'

class DownloadedCsvBuilder
  def initialize(input_file)
    @input_file = input_file
    @chunk_size = 200
    @missed_count = 0
    @downloaded_count = 0
    @original_count = 0

    filename = File.basename(input_file, '.*')
    @output_file = File.join(File.dirname(input_file), "#{filename}-downloaded.csv")
    File.delete(@output_file) if File.exist?(@output_file)
  end

  def call
    CSV.foreach(@input_file, headers: false).each_slice(@chunk_size) do |article_list|
      process_article_list(article_list)
    end

    print_summary
  end

  private

  def process_article_list(article_list)
    @original_count += article_list.count

    writable_article_list = []
    article_list.each do |article_item|
      article = Article.new(article_item)

      if article.exist_destionation_file?
        writable_article_list << article_item

        @downloaded_count += 1
      else
        @missed_count += 1
      end
    end

    save_article_list(writable_article_list)
  end

  def save_article_list(article_list)
    return if article_list.count == 0

    WriteArticleListFile.call(article_list:, output_file: @output_file)
  end

  def print_summary
    puts ''
    puts " ~ Original CSV: #{@original_count}"
    puts " ~ Missed: #{@missed_count}"
    puts " ~ Output CSV: #{@downloaded_count}"
    puts ''
  end
end
