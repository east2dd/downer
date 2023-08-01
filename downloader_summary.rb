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
    check_bot
    finalize_download
  end

  private

  def check_bot
    return if context.download_count > 0

    puts 'x Action Required: Bot checking...'
    AsHelper.bypass_botcheck
    close_all_tabs
    sleep(1)

    raise 'Bypassed botcheck.'
  end

  def close_all_tabs
    tab_ids = context.tabs.map { |tab| tab[0] }
    AsHelper.close_tabs(tab_ids)
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
    close_all_tabs

    return unless context.missed_download_count > 2

    AsHelper.close_chrome
    sleep(1)
  end
end
