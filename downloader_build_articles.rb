require 'interactor'
require 'launchy'
require_relative 'article'

class DownloaderBuildArticles
  include Interactor

  def call
    context.starts_at = Time.now
    Article.clear_temp_dir!

    context.missed_article_list ||= []
    context.downloadable_article_list ||= []

    context.article_list.each do |article_data|
      next if article_data[0] == 'id'

      article = Article.new(article_data)
      next if article.exist_destionation_file?

      article.ensure_destination_dir!

      context.downloadable_article_list << article_data
    end
  end
end
