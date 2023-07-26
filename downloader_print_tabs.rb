require 'interactor'
require 'launchy'
require_relative 'as_helper'

class DownloaderPrintTabs
  include Interactor

  def call
    context.tabs.each do |_tab_info|
      tab_id = AsHelper.current_tab_id
      tab = tab_by_id(tab_id)

      if tab.nil? || !ensure_pdf_page
        AsHelper.close_tab_by_id(tab_id)
        next
      end

      download_tab(tab)
      AsHelper.close_tab_by_id(tab_id)
    end
  end

  private

  def download_tab(tab)
    tab_id = tab[0]
    article = tab.last

    return false if article.exist_temp_file?

    puts "... Downing: #{tab_id} | #{article}"

    # print_pdf(article)
    save_pdf(article)

    # if last tab, wait for a while
    return unless tab_id == context.tabs.first[0]

    puts 'INFO: Processed last tab.'
    sleep(3)
  end

  def ensure_pdf_page
    current_url = AsHelper.current_tab_url
    return true if printable_pdf_url?(current_url)
    return false unless current_url.start_with? 'https://www.sciencedirect.com/'

    puts 'x Action Required: Bot checking...'
    bypass_botcheck

    raise 'Bypassed botcheck.'
  end

  def printable_pdf_url?(url)
    url.start_with? 'https://pdf.sciencedirectassets.com'
  end

  def close_all_tabs
    context.tabs.each do |tab|
      tab_id = tab[0]

      AsHelper.close_tab_by_id(tab_id)
      sleep(0.1)
    end
  end

  def bypass_botcheck
    sleep(5)
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

    sleep(15)

    close_all_tabs
  end

  def tab_by_id(id)
    context.tabs.find do |tab|
      tab[0] == id
    end
  end

  def save_pdf(article)
    script = <<~APPLESCRIPT
      tell application "System Events"
        keystroke "s" using {command down}
        delay 1.2
        key code 51 -- 51 is the key code for the delete key
        key code 51
        keystroke "#{article.id}"
      end tell
    APPLESCRIPT

    `osascript -e '#{script}'`

    AsHelper.press_enter
    sleep(0.3)
    true
  end
end
