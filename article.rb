require 'fileutils'

class Article
  attr_reader :id, :link, :title, :year, :publication, :category, :filename, :data

  CURRENT_DIR = File.dirname(File.expand_path(__FILE__))
  DOWNLOAD_DIR = '/Users/xing/Downloads'

  def initialize(data)
    @data = data
    @id, @link, @title, @year, @publication, @category, @filename = data
  end

  def temp_file_path
    "#{DOWNLOAD_DIR}/#{filename}"
  end

  def category_dir
    @category_dir ||= "#{CURRENT_DIR}/downloads/#{category}"
  end

  def destination_dir
    @destination_dir ||= "#{category_dir}/#{@publication}"
  end

  def destination_file_path
    @destination_file_path ||= "#{destination_dir}/#{@filename}"
  end

  def exist_temp_file?
    File.exist?(temp_file_path)
  end

  def exist_destionation_file?
    File.exist?(destination_file_path)
  end

  def ensure_destination_dir!
    return false if Dir.exist?(destination_dir)

    FileUtils.mkpath(destination_dir)
  end

  def to_s
    "#{@id}, #{year}, #{publication}, #{title}"
  end

  def to_a
    data
  end

  def self.clear_temp_dir!
    FileUtils.rm_rf("#{Article::DOWNLOAD_DIR}/.", secure: true)
  end
end
