require 'interactor'
require 'launchy'
require_relative 'as_helper'

CURRENT_DIR = File.dirname(File.expand_path(__FILE__))

class DownloaderOpenTabs
  include Interactor

  def call
    context.tabs = []
    context.download_count = 0
    context.total_download_count = 0

    context.articles.each do |article|
      if article.exist_destionation_file?
        context.total_download_count += 1
        next
      end

      open_and_build_tabs(article)
    end

    wait_for_all_tabs_to_finish_loading if context.tabs.count.positive?
  end

  private

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

    sleep(3)
  end

  def open_and_build_tabs(article)
    Launchy.open(article.link)
    tab_id = AsHelper.current_tab_id

    puts "o-> Opening pdf: #{tab_id} | #{article}"
    context.tabs << [tab_id, article]
    sleep(0.1)
  end
end
