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
    tmp_missing_count = 0
    context.tabs.reverse.each do |tab|
      article = tab[1]
      next if article.exist_temp_file?

      tmp_missing_count += 1
    end

    return unless tmp_missing_count > 0

    wait_seconds = [9, tmp_missing_count * 3].min
    sleep(wait_seconds)
  end

  def build_file_map
    file_map = []
    context.tabs.reverse.each do |tab|
      article = tab[1]
      filename = find_temp_file(article)
      next if filename.nil?

      file_map << [article.temp_file(filename), article.destination_file_path]
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

  def find_temp_file(article)
    pdf_file_names = Dir["#{Article::DOWNLOAD_DIR}/*.pdf"]

    pdf_file_names.find do |file_name|
      file_name.include? article.id
    end
  end
end
