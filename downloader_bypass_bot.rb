require 'fileutils'
require 'interactor'
require_relative 'article'

class DownloaderBypassBot
  include Interactor
  include ActionView::Helpers::DateHelper

  def call
    context.bot_page = false
    context.craft_page = false

    return unless require_bypass?

    bypass_bot
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
    return unless pdf_bot_url?

    context.bot_page = true

    puts 'x Action Required: Bot checking...'
    sleep(4)

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

  def require_bypass?
    pdf_bot_url? || pdf_craft_url?
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
end
