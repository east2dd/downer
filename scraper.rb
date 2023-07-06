require 'selenium-webdriver'
require 'interactor'
require_relative 'scraper_organizer'

class Scraper
  def initialize(url, category, output_file)
    # Initilize the driver with our desired browser

    options = Selenium::WebDriver::Chrome::Options.new
    @driver = Selenium::WebDriver.for(:chrome, options:)

    @url = url

    # Navigate to mercadolibre
    @driver.get url
    @category = category
    @output_file = output_file

    # Define global timeout threshold, when @wait is called, if the program
    # takes more than 20 secs to return something, we'll infer that somethig
    # went wrong and execution will be terminated.
    @wait = Selenium::WebDriver::Wait.new(timeout: 20) # seconds
  end

  def scrape
    context = ScraperOrganizer.call(driver: @driver, wait: @wait, category: @category, output_file: @output_file)

    @driver.quit # Close browser when the task is completed

    context
  end
end
