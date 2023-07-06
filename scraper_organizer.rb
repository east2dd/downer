require 'selenium-webdriver'
require 'interactor'
require_relative 'scrape_article_list'
require_relative 'write_article_list_file'

class ScraperOrganizer
  include Interactor::Organizer

  organize ScrapeArticleList, WriteArticleListFile
end
