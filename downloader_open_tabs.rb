require 'interactor'
require 'launchy'
require_relative 'as_helper'

class DownloaderOpenTabs
  include Interactor

  def call
    context.tabs = []
    context.download_count = 0
    context.total_download_count = context.article_list.count - context.downloadable_article_list.count

    if maybe_retrying?
      context.missed_article_list = context.downloadable_article_list
      return context.skip
    end

    open_tabs(context.downloadable_article_list)

    return context.skip unless context.tabs.count.positive?

    AsHelper.chrome_tabs_wait_until_loaded
  end

  private

  def maybe_retrying?
    return false if context.downloadable_article_list.count == context.article_list.count

    context.downloadable_article_list.count < 10
  end

  def open_tabs(article_list)
    article_list.each do |article_data|
      article = Article.new(article_data)
      open_and_build_tabs(article)
    end
  end

  def open_and_build_tabs(article)
    Launchy.open(article.link)
    tab_id = AsHelper.current_tab_id

    puts "- Opening: #{tab_id} | #{article}"
    context.tabs << [tab_id, article]
    sleep(0.2)
  end
end
