require 'interactor'
require 'launchy'

class DownloaderEnsureDirectories
  include Interactor

  CURRENT_DIR = File.dirname(File.expand_path(__FILE__))

  def call
    context.article_list.each do |article|
      next if article[0] == 'id'

      publication = article[4]
      category = article[5]

      ensure_download_directory(category, publication)
    end
  end

  private

  def ensure_download_directory(category, publication)
    directory_path = CURRENT_DIR + '/downloads/' + category

    # Check if the directory exists
    Dir.mkdir(directory_path) unless Dir.exist?(directory_path)

    directory_path = directory_path + '/' + publication

    # Check if the directory exists
    Dir.mkdir(directory_path) unless Dir.exist?(directory_path)

    directory_path
  end
end
