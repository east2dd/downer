require 'fileutils'
require 'interactor'

class DownloaderMoveFiles
  include Interactor
  include ActionView::Helpers::DateHelper

  CURRENT_DIR = File.dirname(File.expand_path(__FILE__))

  def call
    return if context.tabs.count == 0

    sleep(3)

    move_files
  end

  private

  def move_files
    context.tabs.each do |tab|
      file_path = tab[1]
      article = tab[2]
      downloaded_file_path = "#{context.download_directory}/#{article[0]}.pdf"
      next unless File.exist? downloaded_file_path

      puts "-> Moving file: #{downloaded_file_path} -> #{file_path}"

      FileUtils.mv downloaded_file_path, file_path, force: true
    end
  end
end
