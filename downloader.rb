require 'selenium-webdriver'
require 'interactor'
require_relative 'downloader_organizer'

class Downloader
  def initialize(article_list)
    @article_list = article_list
  end

  def download
    DownloaderOrganizer.call(article_list: @article_list, download_count: 0, total_download_count: 0,
                             missed_download_count: 0)
  end
end
