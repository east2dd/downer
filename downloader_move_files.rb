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
    sleep(2)

    all_file_count = Dir["#{Article::DOWNLOAD_DIR}/*"].count
    tmp_missing_count = all_file_count - temp_file_count
    craft_pages_count = context.tabs.count - all_file_count
    craft_times = [craft_pages_count].min

    bypass_bot_page
    bypass_craft_page(0, 2)

    if !context.bot_page && context.craft_page
      craft_times.times do |_i|
        AsHelper.chrome_tabs_open_previous_tab

        bypass_craft_page(0, 0)
      end
    end

    sleep(2) if context.craft_page

    seconds = files_wait_seconds(tmp_missing_count)
    puts "~ Waiting: #{seconds} seconds for missing files..."
    sleep(seconds)
  end

  def files_wait_seconds(file_count)
    seconds_per_file = 1

    file_count * seconds_per_file
  end

  def bypass_bot_page
    return unless pdf_bot_url?

    context.bot_page = true

    puts 'x Action Required: Bot checking...'
    sleep(2)

    AsHelper.bypass_botcheck
    sleep(12)

    bypass_craft_page(0, 4)
  end

  def bypass_craft_page(seconds_before = 2, seconds_after = 4)
    return unless pdf_craft_url?

    context.craft_page = true

    puts '~ Waiting: craft pass...'

    sleep(seconds_before)
    AsHelper.bypass_times(2)
    sleep(seconds_after)
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
