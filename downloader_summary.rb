require 'interactor'
require 'puppeteer'
require 'action_view'
require 'launchy'
require_relative 'as_helper'

class DownloaderSummary
  include Interactor
  include ActionView::Helpers::DateHelper

  def call
    context.missed_article_list ||= []

    print_summary
    finalize_download
  end

  private

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

    seconds = Time.now.to_i - context.starts_at.to_i
    speed = (context.download_count.to_f * 3600 / seconds).to_i

    puts "  ~ Summary: #{context.download_count} downloaded, #{context.missed_download_count} missed, #{seconds} seconds"
    puts "  ~ Speed: #{speed}/h"
    puts ''
  end

  def finalize_download
    return close_chrome_and_relaunch if context.tabs.count > 24 || context.missed_download_count > 2

    close_all_tabs
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
end
