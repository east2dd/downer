require 'fileutils'
require 'interactor'
require_relative 'article'

class DownloaderMoveFiles
  include Interactor
  include ActionView::Helpers::DateHelper

  CURRENT_DIR = File.dirname(File.expand_path(__FILE__))

  def call
    return true if context.tabs.count == 0

    sleep(6)

    move_files
  end

  private

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
