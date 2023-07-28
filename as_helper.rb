module AsHelper
  extend self

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
