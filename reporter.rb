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
    @invalid_article_list = []
    @sanitizable_article_list = []
  end

  def call
    @starts_at = Time.now

    CSV.foreach(@input_file, headers: false).each_slice(@chunk_size) do |article_list|
      process_article_list(article_list)
    end

    print_total_summary
  end

  private

  def process_article_list(article_list)
    article_list.each do |article_item|
      process_article_item(article_item)
    end

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

    @sanitizable_article_list << article.to_a if sanitizable?(article)

    return if article.file_size / 1024 > 150 # file size in kb
    return if article.page_count > 5

    @one_page_article_list << article.to_a if article.page_count == 1
    @two_page_article_list << article.to_a if article.page_count == 2
    @invalid_article_list << article.to_a if article.page_count == -1
  end

  def sanitizable?(article)
    article.title.downcase.include? 'korea'
  end

  def print_summary
    download_percent = (@download_count / @total_count.to_f) * 100

    puts ''
    puts "  ~ Download percent: #{download_percent.round(2)}% (#{@download_count} / #{@total_count})"
    puts "  ~ Download missed: #{@missed_article_list.count}"
    puts "  ~ One page: #{@one_page_article_list.count}"
    puts "  ~ Two pages: #{@two_page_article_list.count}"
    puts "  ~ Invalid PDF: #{@invalid_article_list.count}"
    puts "  ~ Sanitizable: #{@sanitizable_article_list.count}"
    puts ''
  end

  def print_total_summary
    puts 'Done!'
  end
end
