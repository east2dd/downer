require 'action_view'
require_relative 'downloader'

class CsvDownloader
  include ActionView::Helpers::DateHelper

  def initialize(input_file, chunk_size = 16)
    @input_file = input_file
    @chunk_size = chunk_size

    article_list = CSV.read(input_file)
    @total_count = article_list.count
    @total_download_count = 0
    @missed_download_count = 0
    @download_count = 0

    @missed_article_list = []
  end

  def call
    @starts_at = Time.now

    CSV.foreach(@input_file, headers: false).each_slice(@chunk_size) do |article_list|
      download(article_list)
      next unless @missed_article_list.count > 10

      puts 'INFO: Processing missed articles...'
      download(@missed_article_list)
      @missed_article_list = []
    end

    download(@missed_article_list)
  end

  private

  def download(article_list)
    if article_list.count < 5
      @missed_article_list += article_list
      return false
    end

    retry_attempts = 3
    context = Downloader.new(article_list).download
    @download_count += context.download_count
    @total_download_count += context.total_download_count
    @missed_article_list += context.missed_article_list

    print_total_summary
  rescue StandardError => e
    retry_attempts -= 1

    puts e.message
    puts e.backtrace
    puts 'x Retrying...'

    sleep(1)
    retry if retry_attempts > 0
  end

  def print_total_summary
    time_in_words = distance_of_time_in_words(@starts_at, Time.now)
    hours = (Time.now.to_i - @starts_at.to_i).to_f / 3600.0
    return if hours < 0.01

    speed = (@download_count.to_f / hours).to_i
    download_percent = (@total_download_count / @total_count.to_f) * 100
    puts ''
    puts "  ~ Download percent: #{download_percent.round(2)}% (#{@total_download_count} / #{@total_count})"
    puts "  ~ Download missed: #{@missed_article_list.count}"
    puts "  ~ Download speed: #{speed}/h (#{@download_count} downloaded, #{time_in_words} ellapsed)"
    puts ''
    puts '--------------------------------'
  end
end
