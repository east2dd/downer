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

    if tmp_missing_count > 0
      wait_seconds = [12, tmp_missing_count * 3].min
      sleep(wait_seconds)
    end
  end

  def move_files
    context.tabs.reverse.each do |tab|
      article = tab[1]

      next unless article.exist_temp_file?

      puts "-> Moving file: #{article.temp_file_path} -> #{article.destination_file_path}"

      FileUtils.mv article.temp_file_path, article.destination_file_path, force: true
    end

    Article.clear_temp_dir!
  end
end
