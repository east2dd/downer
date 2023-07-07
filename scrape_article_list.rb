require 'selenium-webdriver'
require 'interactor'
require 'date'
require 'digest'

class ScrapeArticleList
  include Interactor

  def call
    # Executes block while the next button is visible
    # If it's not it means that we are already on the last page
    # return unless nxt_button_visible?(context.wait, context.driver)

    wait_until_pagination_visible(context.wait, context.driver)
    fetch_titles(context.driver, context.wait)

    return unless nxt_button_visible?(context.driver)

    nxt_element = nxt_button(context.driver)
    href = nxt_element.attribute('href')
    context.next_url = href
  end

  private

  # Finds the next button
  def nxt_button(driver)
    driver.find_element(:css, 'li.pagination-link.next-link a')
  end

  # displayed? tells us if the element is present in the DOM
  def nxt_button_visible?(driver)
    driver.find_element(:css, 'li.pagination-link.next-link a')
    true
  rescue Selenium::WebDriver::Error::NoSuchElementError
    false
  end

  def wait_until_pagination_visible(wait, driver)
    wait.until { pagination_element(driver).displayed? }
  end

  def pagination_element(driver)
    driver.find_element(:css, '#srp-pagination')
  end

  def fetch_titles(driver, wait)
    # Finds the titles displayed in the current page
    items = wait.until do
      driver.find_elements(:css, '.result-item-content')
    end

    sleep(1)

    article_list = []

    items.each do |item|
      record = article_record_from_item(item)
      puts record.join('--')

      article_list << record
    end

    context.article_list = article_list
  end

  def article_record_from_item(item)
    title = title_from_item(item)
    year = year_from_item(item)
    category = context.category
    link = link_from_item(item)
    # id = generate_10_char_hash(link)
    id = extract_id_from_url(link)
    # download_link = download_link_from_item(item)

    [id, link, title, year, category, id]
  end

  def link_from_item(item)
    item.find_element(:class, 'result-list-title-link').attribute('href')
  end

  def title_from_item(item)
    item.find_element(:class, 'result-list-title-link').text
  end

  def access_label_from_item(item)
    access_label = begin
      item.find_element(:class, 'access-label')
    rescue StandardError
      nil
    end

    access_label&.text
  end

  def year_from_item(item)
    date_fields = item.find_element(:class, 'srctitle-date-fields')
    child_spans = date_fields.find_elements(:tag_name, 'span')
    date_string = child_spans.last.text
    date = Date.parse(date_string)

    date.year
  end

  def download_link_from_item(item)
    item.find_element(:css, '.DownloadPdf .download-link').attribute('href')
  end

  def generate_10_char_hash(text)
    sha256_hash = Digest::SHA256.hexdigest(text)
    sha256_hash[0..9]
  end

  def extract_id_from_url(url)
    url.split('/').last
  end
end
