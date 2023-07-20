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
    @download_count = 0
  end

  def call
    @starts_at = Time.now

    CSV.foreach(@input_file, headers: true).each_slice(@chunk_size) do |article_list|
      context = Downloader.new(article_list).download
      @download_count += context.download_count
      @total_download_count += context.total_download_count

      print_download_summary
    end
  end

  def print_download_summary
    time_in_words = distance_of_time_in_words(@starts_at, Time.now)
    hours = (Time.now.to_i - @starts_at.to_i).to_f / 3600.0
    return if hours < 0.01

    speed = (@download_count.to_f / hours).to_i
    download_percent = (@total_download_count / @total_count.to_f) * 100
    puts ''
    puts "  ~ Download percent: #{download_percent.round(2)}% (#{@total_download_count} / #{@total_count})"
    puts "  ~ Download speed: #{speed}/h (#{@download_count} downloaded, #{time_in_words} ellapsed)"
    puts ''
    puts '--------------------------------'
  end
end
