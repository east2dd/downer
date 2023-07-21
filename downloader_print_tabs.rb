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

      article = tab[2]
      article_id = article[0]
      article_title = article[2]

      puts "... Downloading: #{article_id}, #{article_title}"

      current_url = current_tab_url
      unless printable_pdf_url?(current_url)
        puts 'x Action Required: Please bypass bot checking and continue!!!'
        puts current_url

        bypass_botcheck

        raise 'Bypassed botcheck.'
      end

      print_pdf(tab[1])
      close_tab_by_id(tab[0])
    end
  end

  private

  def printable_pdf_url?(url)
    url.start_with? 'https://pdf.sciencedirectassets.com'
  end

  def close_all_tabs
    context.tabs.each do |tab|
      tab_id = tab[0]

      close_tab_by_id(tab_id)
      sleep(0.3)
    end
  end

  def bypass_botcheck
    script = <<~APPLESCRIPT
      tell application "System Events"
        keystroke tab
        delay 0.5
        keystroke space
        delay 0.5
      end tell
    APPLESCRIPT

    6.times do |_index|
      `osascript -e '#{script}'`
    end

    close_all_tabs
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

    sleep(2)
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

  def clipboard_text
    script = <<~APPLESCRIPT
      set theData to (the clipboard as text)
    APPLESCRIPT

    `osascript -e '#{script}'`.strip
  end

  def print_pdf(file_path)
    file, _delimiter, _ext = file_path.rpartition('.')

    copy_to_clipboard(file)
    sleep(0.1)
    clipboard_file = clipboard_text
    sleep(0.1)

    return false if clipboard_file != file

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
        delay 0.5
        key code 36
      end tell
    APPLESCRIPT

    `osascript -e '#{script}'`
    sleep(0.5)

    script_after = <<~APPLESCRIPT
      tell application "System Events"
        key code 36 -- 36 is the key code for the Enter key
        delay 0.5
        key code 36
      end tell
    APPLESCRIPT

    `osascript -e '#{script_after}'`
    sleep(0.5)

    true
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
