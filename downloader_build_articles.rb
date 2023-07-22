require 'interactor'
require 'launchy'
require_relative 'article'

class DownloaderBuildArticles
  include Interactor

  def call
    Article.clear_temp_dir!

    context.articles = []

    context.article_list.each do |article_data|
      next if article_data[0] == 'id'

      article = Article.new(article_data)
      article.ensure_destination_dir!

      context.articles << article
    end
  end
end
