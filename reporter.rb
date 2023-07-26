require 'action_view'
require 'pdf-reader'
require 'csv'
require_relative 'article'
require_relative 'write_article_list_file'

class Reporter
  include ActionView::Helpers::DateHelper

  def initialize(input_file)
    @input_file = input_file
    @chunk_size = 100

    article_list = ::CSV.read(input_file)
    @total_count = article_list.count

    @download_count = 0
    @missed_article_list = []

    @one_page_article_list = []
    @two_page_article_list = []

    @wrongable_article_list = []
  end

  def call
    @starts_at = Time.now

    CSV.foreach(@input_file, headers: false).each_slice(@chunk_size) do |article_list|
      process_article_list(article_list)
    end

    # delete_wrong_files
    build_extra_csv
  end

  private

  def process_article_list(article_list)
    article_list.each do |article_item|
      process_article_item(article_item)
    end

    build_extra_csv
    print_summary
  end

  def process_article_item(article_item)
    article = Article.new(article_item)

    if article.exist_destionation_file?
      process_downloaded_article(article)
    else
      process_missed_article(article)
    end
  end

  def process_missed_article(article)
    @missed_article_list << article.to_a
  end

  def process_downloaded_article(article)
    @download_count += 1

    return if article.file_size / 1024 > 200 # file size in kb
    return if article.page_count > 5

    @one_page_article_list << article.to_a if article.page_count == 1
    @two_page_article_list << article.to_a if article.page_count == 2

    return if article.page_count > 2

    @wrongable_article_list << article.to_extra_a
  end

  def print_summary
    download_percent = (@download_count / @total_count.to_f) * 100

    puts ''
    puts "  ~ Download percent: #{download_percent.round(2)}% (#{@download_count} / #{@total_count})"
    puts "  ~ Download missed: #{@missed_article_list.count}"
    puts "  ~ One page: #{@one_page_article_list.count}"
    puts "  ~ Two pages: #{@two_page_article_list.count}"
    puts ''
    puts '--------------------------------'
  end

  def delete_wrong_files
    return false if @one_page_article_list.count == 0

    puts 'Deleting wrong files!'
    @one_page_article_list.each do |article_item|
      article = Article.new(article_item)

      if article.page_count == 1 && article.maybe_wrong?
        puts "x Deleting: #{article}"
        article.delete_destination_file!
      end
    end
  end

  def build_extra_csv
    output_file = 'article_list-extra.csv'
    WriteArticleListFile.call(output_file:, article_list: @wrongable_article_list)
    @wrongable_article_list = []
  end
end
