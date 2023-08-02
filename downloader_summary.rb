require 'interactor'
require 'puppeteer'
require 'action_view'
require 'launchy'
require_relative 'as_helper'

CURRENT_DIR = File.dirname(File.expand_path(__FILE__))

class DownloaderSummary
  include Interactor
  include ActionView::Helpers::DateHelper

  def call
    context.missed_article_list ||= []
    return if context.tabs.count == 0

    print_summary
    bypass_bot_page
    finalize_download
  end

  private

  def bypass_bot_page
    return if context.download_count > 0

    puts 'x Action Required: Bot checking...'
    sleep(4)

    AsHelper.bypass_botcheck
    sleep(8)

    bypass_craft_page

    close_chrome_and_relaunch

    raise 'Bypassed botcheck!'
  end

  def bypass_craft_page
    return unless pdf_craft_url?

    puts '~ Waiting: craft pass...'
    AsHelper.bypass_botcheck

    sleep(8)
  end

  def print_summary
    context.tabs.each do |tab|
      article = tab.last

      if article.exist_destionation_file?
        context.download_count += 1
        context.total_download_count += 1
      else
        context.missed_download_count += 1
        puts "  x Missing: #{article}"

        context.missed_article_list << article.to_a
      end
    end

    puts "  ~ Summary: #{context.download_count} downloaded, #{context.missed_download_count} missed"
    puts ''
  end

  def finalize_download
    return close_chrome_and_relaunch if context.tabs.count > 24 || context.missed_download_count > 2

    close_all_tabs
  end

  def pdf_craft_url?
    AsHelper.current_tab_url.start_with? 'https://pdf.sciencedirectassets.com/craft'
  end

  def close_chrome_and_relaunch
    AsHelper.close_chrome
    sleep(1)

    Launchy.open('https://google.com')
    sleep(1)
  end

  def close_all_tabs
    tab_ids = context.tabs.reverse.map { |tab| tab[0] }
    AsHelper.close_tabs(tab_ids)
  end

  def pdf_bot_url?
    AsHelper.current_tab_url.start_with? 'https://www.sciencedirect.com/'
  end
end
