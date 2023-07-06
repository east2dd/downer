require 'interactor'
require_relative 'download_article_pdf'

class DownloaderOrganizer
  include Interactor::Organizer

  organize DownloadArticlePdf
end
