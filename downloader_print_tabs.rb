require 'interactor'
require 'puppeteer'
require 'action_view'
require 'launchy'

CURRENT_DIR = File.dirname(File.expand_path(__FILE__))

class DownloaderPrintTabs
  include Interactor
  include ActionView::Helpers::DateHelper

  def call
    wait_for_all_tabs_to_finish_loading if context.tabs.count.positive?

    context.tabs.each do |_tab_info|
      tab_id = current_tab_id
      tab = tab_by_id(tab_id)

      puts "... Downloading: #{tab[2]}"

      unless printable_pdf_url?(url)
        puts 'x Action Required: Please bypass bot checking and continue!!!'
        puts current_tab_url
        exit
      end

      print_pdf(tab[1])
      close_tab_by_id(tab[0])
    end
  end

  private

  def printable_pdf_url?(url)
    url.start_with? 'https://pdf.sciencedirectassets.com'
  end

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

  def current_tab_url
    script = <<~APPLESCRIPT
      tell application "Google Chrome"
        get URL of active tab of first window
      end tell
    APPLESCRIPT

    `osascript -e '#{script}'`.strip
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

    sleep(1)
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
    file, _delimiter, _ext = file_path.rpartition('.')

    copy_to_clipboard(file)

    script = <<~APPLESCRIPT
      tell application "System Events"
        keystroke "p" using {command down}
        delay 2
        keystroke return
        delay 0.5
        keystroke "g" using {command down, shift down}
        delay 0.5
        key code 44 -- 44 is the key code for the slash key
        delay 0.2
        key code 51 -- 51 is the key code for the delete key
        delay 0.2
        keystroke "v" using {command down}
        delay 0.2
        key code 36 -- 36 is the key code for the Enter key
        delay 0.6
        key code 36
      end tell
    APPLESCRIPT

    # Use the `osascript` command-line utility to execute the AppleScript
    `osascript -e '#{script}'`
    sleep(0.5)

    script_after = <<~APPLESCRIPT
      tell application "System Events"
        key code 36 -- 36 is the key code for the Enter key
        delay 0.5
        key code 36
        delay 0.5
        key code 36
      end tell
    APPLESCRIPT

    `osascript -e '#{script_after}'`
    sleep(0.5)
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
