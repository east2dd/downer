require 'interactor'
require_relative 'downloader_ensure_directories'
require_relative 'downloader_open_tabs'
require_relative 'downloader_print_tabs'
require_relative 'downloader_summary'

# require_relative 'download_article_pdf'

class DownloaderOrganizer
  include Interactor::Organizer

  # organize DownloadArticlePdf
  organize DownloaderEnsureDirectories, DownloaderOpenTabs, DownloaderPrintTabs, DownloaderSummary
end
