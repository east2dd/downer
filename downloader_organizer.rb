require 'interactor'
require_relative 'downloader_build_articles'
require_relative 'downloader_open_tabs'
require_relative 'downloader_print_tabs'
require_relative 'downloader_move_files'
require_relative 'downloader_summary'

# require_relative 'download_article_pdf'

class DownloaderOrganizer
  include Interactor::Organizer

  # DownloaderPrintTabs - save files in PDF if chrome is opening PDF
  organize DownloaderBuildArticles, DownloaderOpenTabs, DownloaderMoveFiles, DownloaderSummary
end
