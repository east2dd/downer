require 'fileutils'
require 'interactor'
require_relative 'article'

class DownloaderMoveFiles
  include Interactor
  include ActionView::Helpers::DateHelper

  CURRENT_DIR = File.dirname(File.expand_path(__FILE__))

  def call
    return true if context.tabs.count == 0

    wait_download
    move_files
  end

  private

  def wait_download
    sleep(3) if pdf_craft_url?

    all_file_count = Dir["#{Article::DOWNLOAD_DIR}/*"].count

    sleep(3) if all_file_count == 0

    tmp_missing_count = all_file_count - temp_file_count

    puts "Waiting: #{temp_file_count}"
    sleep(tmp_missing_count)
  end

  def pdf_craft_url?
    AsHelper.current_tab_url.start_with? 'https://pdf.sciencedirectassets.com/craft'
  end

  def temp_file_count
    Dir["#{Article::DOWNLOAD_DIR}/*.pdf"].count
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
