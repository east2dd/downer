require 'interactor'
require 'puppeteer'
require 'action_view'
require 'launchy'

CURRENT_DIR = File.dirname(File.expand_path(__FILE__))

class DownloaderPrintTabs
  include Interactor
  include ActionView::Helpers::DateHelper

  def call
    context.tabs.each do |_tab_info|
      tab_id = current_tab_id
      tab = tab_by_id(tab_id)
      puts "... Downloading: #{tab[1]}, #{tab[2]}"
      print_pdf(tab[1])
      sleep(1)
      close_tab_by_id(tab[0])
    end
  end

  private

  def print_tabs
    context.tabs.each do |tab_info|
      puts tab_info
    end
  end

  def tab_by_id(id)
    context.tabs.find do |tab|
      tab[0] == id
    end
  end

  def current_tab_id
    script = <<~APPLESCRIPT
      tell application "Google Chrome"
        set currentTabID to id of active tab of front window
      end tell
      return currentTabID
    APPLESCRIPT

    `osascript -e '#{script}'`.strip
  end

  def print_pdf(file_path)
    script = <<~APPLESCRIPT
      tell application "System Events"
        keystroke "p" using {command down}
        delay 1 -- Adjust this delay as needed to allow the print dialog to open.
        keystroke return
        delay 1
        keystroke "g" using {command down, shift down}
        delay 1
        keystroke "#{file_path}"
        delay 1
        keystroke return
        delay 1
        keystroke return
        delay 1
        keystroke return
      end tell
    APPLESCRIPT

    # Use the `osascript` command-line utility to execute the AppleScript
    `osascript -e '#{script}'`
  end

  def close_tab_by_id(tab_id)
    script = <<~APPLESCRIPT
      tell application "Google Chrome"
        set targetTab to (every tab whose id is #{tab_id}) of front window
        if (count of targetTab) > 0 then
          close item 1 of targetTab
        end if
      end tell
    APPLESCRIPT

    `osascript -e '#{script}'`
  end
end
