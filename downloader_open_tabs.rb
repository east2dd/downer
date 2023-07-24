require 'interactor'
require 'launchy'
require_relative 'as_helper'

CURRENT_DIR = File.dirname(File.expand_path(__FILE__))

class DownloaderOpenTabs
  include Interactor

  def call
    context.tabs = []
    context.download_count = 0
    context.total_download_count = context.article_list.count - context.downloadable_article_list.count

    if maybe_retrying?
      context.missed_article_list = context.downloadable_article_list
      return context.skip
    end

    open_tabs(context.downloadable_article_list)

    return unless context.tabs.count.positive?

    wait_for_all_tabs_to_finish_loading

    if context.tabs.count < 3
      sleep(5)
    else
      sleep(3)
    end
  end

  private

  def maybe_retrying?
    return false if context.downloadable_article_list.count == context.article_list.count

    context.downloadable_article_list.count < 6
  end

  def open_tabs(article_list)
    article_list.each do |article_data|
      article = Article.new(article_data)
      open_and_build_tabs(article)
    end
  end

  def wait_for_all_tabs_to_finish_loading
    script = <<~APPLESCRIPT
      tell application "Google Chrome"
        set allTabsLoaded to false
        repeat until allTabsLoaded is true
          set allTabsLoaded to true
          repeat with theWindow in windows
            repeat with theTab in tabs of theWindow
              if loading of theTab is true then
                set allTabsLoaded to false
                exit repeat
              end if
            end repeat
          end repeat

          if allTabsLoaded is false then
            delay 1
          end if
        end repeat
      end tell
    APPLESCRIPT

    `osascript -e '#{script}'`
  end

  def open_and_build_tabs(article)
    Launchy.open(article.link)
    tab_id = AsHelper.current_tab_id

    puts "* Opening pdf: #{tab_id} | #{article}"
    context.tabs << [tab_id, article]
    sleep(0.1)
  end
end
