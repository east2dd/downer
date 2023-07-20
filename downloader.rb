require 'selenium-webdriver'
require 'interactor'
require_relative 'downloader_organizer'

class Downloader
  def initialize(article_list)
    @article_list = article_list

    # @driver = Selenium::WebDriver.for :chrome
    # @wait = Selenium::WebDriver::Wait.new(timeout: 20) # seconds
  end

  def download
    # Calling interactor that orchestrates the scraper's logic
    # Organizer.call(driver: @driver, wait: @wait)
    DownloaderOrganizer.call(article_list: @article_list, download_count: 0, total_download_count: 0)

    # @driver.quit # Close browser when the task is completed
  end
end
