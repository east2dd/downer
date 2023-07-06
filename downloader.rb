require 'selenium-webdriver'
require 'interactor'
require_relative 'downloader_organizer'

class Downloader
  def initialize(article_list)
    # Initilize the driver with our desired browser
    @driver = Selenium::WebDriver.for :chrome
    @article_list = article_list

    # Define global timeout threshold, when @wait is called, if the program
    # takes more than 10 secs to return something, we'll infer that somethig
    # went wrong and execution will be terminated.
    @wait = Selenium::WebDriver::Wait.new(timeout: 20) # seconds
  end

  def download
    # Calling interactor that orchestrates the scraper's logic
    # Organizer.call(driver: @driver, wait: @wait)
    context = DownloaderOrganizer.call(driver: @driver, wait: @wait, article_list: @article_list, download_count: 0)

    @driver.quit # Close browser when the task is completed

    context
  end
end
