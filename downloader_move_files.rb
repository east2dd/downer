require 'fileutils'
require 'interactor'
require_relative 'article'

class DownloaderMoveFiles
  include Interactor
  include ActionView::Helpers::DateHelper

  def call
    wait_download
    move_files
  end

  private

  def wait_download
    puts '~ Waiting Download: ...'

    wait_seconds = 0
    loop do
      break if temp_missing_count == 0
      break if wait_seconds == 12

      sleep(1)
      wait_seconds += 1
    end

    puts "~ Waiting Download: Done, #{wait_seconds} seconds"
  end

  def temp_missing_count
    all_file_count = Dir["#{Article::DOWNLOAD_DIR}/*"].count
    temp_file_count = Dir["#{Article::DOWNLOAD_DIR}/*.pdf"].count

    all_file_count - temp_file_count
  end

  def build_file_map
    file_map = []
    context.tabs.reverse.each do |tab|
      article = tab[1]
      temp_file_path = find_temp_file_path(article)
      next if temp_file_path.nil?

      file_map << [temp_file_path, article.destination_file_path]
    end

    file_map
  end

  def move_files
    file_map = build_file_map

    file_map.each do |mapping|
      puts "> Moving: #{mapping[0]} -> #{mapping[1]}"

      FileUtils.mv mapping[0], mapping[1], force: true
    end
  end

  def find_temp_file_path(article)
    pdf_file_names = Dir["#{Article::DOWNLOAD_DIR}/*.pdf"]

    pdf_file_names.find do |file_name|
      file_name.include? article.id
    end
  end
end
