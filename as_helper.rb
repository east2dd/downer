module AsHelper
  extend self

  def current_wifi_network_name
    script = <<~APPLESCRIPT
      do shell script "networksetup -getairportnetwork en1"
    APPLESCRIPT

    result = `osascript -e '#{script}'`.strip # Current Wi-Fi Network: XXXX

    result.split('Current Wi-Fi Network: ').last.strip
  end

  def connect_wifi_network(network_name)
    script = <<~APPLESCRIPT
      do shell script "networksetup -setairportnetwork en1 #{network_name} wemteqdev2018"
    APPLESCRIPT

    `osascript -e '#{script}'`.strip
  end

  def available_wifi_network_names
    %w[WEMTEQ-SEDANKA US-IL US-SL US-WA US-VA]
  end

  def connect_other_network
    network = current_wifi_network_name
    puts "Wifi: Current network is #{network}"
    next_network_index = available_wifi_network_names.index(network) - 1

    next_network = available_wifi_network_names[next_network_index]

    puts "Wifi: Connecting to #{next_network}"
    connect_wifi_network(next_network)
  end

  def bypass_botcheck
    bypass_times(4)
  end

  def chrome_tabs_open_previous_tab
    press_ctrl_shift_tab
  end

  def press_ctrl_shift_tab
    script = <<~APPLESCRIPT
      tell application "System Events"
        keystroke (tab) using {control down, shift down}
      end tell
    APPLESCRIPT

    `osascript -e '#{script}'`
  end

  def bypass_times(i)
    script = <<~APPLESCRIPT
      tell application "System Events"
        keystroke tab
        delay 0.2
        keystroke space
      end tell
    APPLESCRIPT

    i.times do |_index|
      `osascript -e '#{script}'`
    end
  end

  def close_tabs(tab_ids)
    tab_ids.each do |tab_id|
      close_tab_by_id(tab_id)
    end
  end

  def chrome_tabs_wait_until_loaded
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
            delay 2
          end if
        end repeat
      end tell
    APPLESCRIPT

    `osascript -e '#{script}'`
  end

  def chrome_tabs_count
    script = <<~APPLESCRIPT
      tell application "Google Chrome"
        set windowCount to count windows
        set tabCount to 0
        repeat with theWindow in windows
            set tabCount to tabCount + (count of tabs of theWindow)
        end repeat
      end tell

      if windowCount > 0 and tabCount > 0 then
        return tabCount -- There are open tabs
      else
        return 0
      end if
    APPLESCRIPT

    `osascript -e '#{script}'`.to_i
  end

  def keystroke(string)
    script = <<~APPLESCRIPT
      tell application "System Events"
        keystroke "#{string}"
      end tell
    APPLESCRIPT

    `osascript -e '#{script}'`
  end

  def close_chrome
    script = <<~APPLESCRIPT
      set processname to "Google Chrome"
      do shell script "killall -9 " & quoted form of processname
    APPLESCRIPT

    `osascript -e '#{script}'`
  end

  def open_chrome
    script = <<~APPLESCRIPT
      tell application "Google Chrome"
        activate
      end tell
    APPLESCRIPT

    `osascript -e '#{script}'`
  end

  def current_tab_url
    script = <<~APPLESCRIPT
      tell application "Google Chrome"
        get URL of active tab of front window
      end tell
    APPLESCRIPT

    `osascript -e '#{script}'`.strip
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

  def press_enter
    script = <<~APPLESCRIPT
      tell application "System Events"
        key code 36
      end tell
    APPLESCRIPT

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

  def press_quit_window
    # cmd + alt + q

    script = <<~APPLESCRIPT
      tell application "System Events"
        key code 12 using {command down, option down}
      end tell
    APPLESCRIPT

    `osascript -e '#{script}'`
  end
end
