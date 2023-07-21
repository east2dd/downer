require 'interactor'
require 'launchy'

CURRENT_DIR = File.dirname(File.expand_path(__FILE__))

class DownloaderOpenTabs
  include Interactor

  def call
    context.tabs = []
    context.download_count = 0
    context.total_download_count = 0

    context.article_list.each do |article|
      next if article[0] == 'id'

      pdf_file_path = build_pdf_file_path(article)

      if File.exist?(pdf_file_path)
        context.total_download_count += 1
        next
      end

      url = article[1]
      open_pdf(url, pdf_file_path, article)
    end
  end

  private

  def build_pdf_file_path(article)
    id = article[0]
    publication = article[4]
    category = article[5]

    "#{CURRENT_DIR}/downloads/#{category}/#{publication}/#{id}.pdf"
  end

  def build_tabs(file_path, title)
    last_tab_script = <<~APPLESCRIPT
      tell application "Google Chrome"
        set allWindows to windows
        set lastWindow to item -1 of allWindows
        set currentTab to active tab of lastWindow
        set currentTabID to id of currentTab
      end tell
    APPLESCRIPT

    tab_id = `osascript -e '#{last_tab_script}'`.strip

    context.tabs << [tab_id, file_path, title]
  end

  def open_pdf(url, pdf_file_path, article)
    article_id = article[0]
    article_title = article[2]
    article_year = article[3]
    article_publication = article[4]

    puts "o-> Opening pdf: #{article_id}, #{article_year}, #{article_publication}"

    Launchy.open(url)
    sleep(0.5)
    build_tabs(pdf_file_path, article_title)
  end
end
