require 'fileutils'
require 'interactor'
require_relative 'article'

class DownloaderMoveFiles
  include Interactor
  include ActionView::Helpers::DateHelper

  CURRENT_DIR = File.dirname(File.expand_path(__FILE__))

  def call
    context.bot_page = false
    context.craft_page = false

    return true if context.tabs.count == 0

    wait_download
    move_files
  end

  private

  def wait_download
    sleep(4)

    bypass_bot_page
    bypass_craft_page

    if !context.bot_page && context.craft_page
      AsHelper.close_tab_by_id(AsHelper.current_tab_id)

      bypass_craft_page
    end

    sleep(4) if context.craft_page

    all_file_count = Dir["#{Article::DOWNLOAD_DIR}/*"].count

    tmp_missing_count = all_file_count - temp_file_count

    seconds = files_wait_seconds(tmp_missing_count)
    puts "Waiting: #{seconds} seconds for missing files"
    sleep(seconds)
  end

  def files_wait_seconds(file_count)
    seconds_per_file = 0.6

    file_count * seconds_per_file
  end

  def bypass_bot_page
    return unless pdf_bot_url?

    context.bot_page = true

    puts 'x Action Required: Bot checking...'
    sleep(2)

    AsHelper.bypass_botcheck
    sleep(12)

    bypass_craft_page
    sleep(4)
  end

  def bypass_craft_page
    return unless pdf_craft_url?

    context.craft_page = true

    sleep(2)
    puts '~ Waiting: craft pass...'
    AsHelper.bypass_botcheck
  end

  def pdf_bot_url?
    current_url = AsHelper.current_tab_url
    return false unless current_url.start_with? 'https://www.sciencedirect.com/'

    uri = URI.parse(current_url)
    return false if uri.path.end_with?('/pdfft') || uri.path.end_with?('/pdf')

    true
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
