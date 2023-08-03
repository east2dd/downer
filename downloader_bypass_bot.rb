require 'fileutils'
require 'interactor'
require_relative 'article'

class DownloaderBypassBot
  include Interactor
  include ActionView::Helpers::DateHelper

  def call
    context.bot_page = false
    context.craft_page = false

    check_ip_blocked

    return unless require_bypass?

    bypass_bot

    check_ip_blocked
  end

  private

  def bypass_bot
    sleep(2)

    bypass_bot_page
    bypass_craft_page(0, 2)
    bypass_craft_page_list
  end

  def bypass_craft_page_list
    return if context.bot_page
    return unless context.craft_page

    craft_pages_count.times do |_i|
      AsHelper.chrome_tabs_open_previous_tab

      bypass_craft_page(0, 0)
    end

    sleep(2)
  end

  def craft_pages_count
    all_file_count = Dir["#{Article::DOWNLOAD_DIR}/*"].count

    context.tabs.count - all_file_count
  end

  def bypass_bot_page
    return unless sd_bot_url?(AsHelper.current_tab_url)

    context.bot_page = true

    puts 'x Action Required: Bot checking...'

    sleep(4)
    AsHelper.bypass_botcheck
    sleep(12)

    bypass_craft_page(0, 4)
  end

  def check_ip_blocked
    return unless require_ip_change?

    puts ''
    puts 'Breaking:'
    puts 'x Please use different IP address...'
    puts ''

    exit
  end

  def require_ip_change?
    pdf_main_url?(AsHelper.current_tab_url) && files_count.zero?
  end

  def files_count
    Dir["#{Article::DOWNLOAD_DIR}/*"].count
  end

  def bypass_craft_page(seconds_before = 2, seconds_after = 4)
    return unless pdf_craft_url?(AsHelper.current_tab_url)

    context.craft_page = true

    puts '~ Waiting: craft pass...'

    sleep(seconds_before)
    AsHelper.bypass_times(2)
    sleep(seconds_after)
  end

  def require_bypass?
    current_tab_url = AsHelper.current_tab_url

    sd_bot_url?(current_tab_url) || pdf_craft_url?(current_tab_url)
  end

  def sd_bot_url?(url)
    sd_url?(url) && !sd_pdf_url?(url)
  end

  def sd_pdf_url?(url)
    return false unless sd_url?(url)

    uri = URI.parse(url)
    uri.path.end_with?('/pdfft') || uri.path.end_with?('/pdf')
  end

  def sd_url?(url)
    url.start_with? 'https://www.sciencedirect.com/'
  end

  def pdf_main_url?(url)
    return false unless pdf_url?(url)

    uri = URI.parse(url)
    uri.path.end_with?('/main.pdf')
  end

  def pdf_url?(url)
    url.start_with? 'https://pdf.sciencedirectassets.com/'
  end

  def pdf_craft_url?(url)
    url.start_with? 'https://pdf.sciencedirectassets.com/craft'
  end
end
