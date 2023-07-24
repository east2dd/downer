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
    context.missed_article_list = []
    return if context.tabs.count == 0

    print_summary
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

    puts "  ~ Summary: #{context.download_count} downloaded, #{context.missed_download_count} missed"
    puts ''

    return unless context.missed_download_count == context.tabs.count

    puts '!!! Breaking: Something wrong, Please force quite browser and restart.'
    sleep(1)
    AsHelper.press_quit_window
    sleep(1)
    raise 'Quit browser and restarting...'
  end
end
