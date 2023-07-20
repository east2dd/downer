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
      sleep(1.5)
      close_tab_by_id(tab[0])

      context.download_count += 1
      context.total_download_count += 1
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

  def copy_to_clipboard(text)
    script = <<~APPLESCRIPT
      set the clipboard to "#{text}"
    APPLESCRIPT

    `osascript -e '#{script}'`
  end

  def print_pdf(file_path)
    file, delimiter, ext = file_path.rpartition('.')
    # copy_to_clipboard(directory)

    # puts directory
    # filename = file.split('.')[0]
    # puts filename

    # keystroke "g" using {command down, shift down}

    script = <<~APPLESCRIPT
      tell application "System Events"
        keystroke "p" using {command down}
        delay 1.5
        keystroke return
        delay 1
        keystroke "g" using {command down, shift down}
        delay 0.5
        key code 44 -- 44 is the key code for the slash key
        delay 0.2
        key code 51 -- 51 is the key code for the delete key
        delay 0.2
        keystroke "#{file}"
        delay 0.2
        key code 36 -- 36 is the key code for the Enter key
        delay 0.5
        key code 36
        delay 0.5
        key code 36
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
