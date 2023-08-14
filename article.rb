require 'fileutils'
require 'pdf-reader'

class Article
  attr_reader :id, :link, :title, :year, :publication, :category, :filename, :data

  CURRENT_DIR = File.dirname(File.expand_path(__FILE__))
  DOWNLOAD_DIR = File.expand_path('~/Downloads')
  DEST_DIR = '/Volumes/Untitled/ScienceDirect'.freeze

  def initialize(data)
    @data = data
    @id, @link, @title, @year, @publication, @category, @filename = data
  end

  def temp_file(name)
    "#{DOWNLOAD_DIR}/#{name}"
  end

  def temp_file_path
    "#{DOWNLOAD_DIR}/#{filename}"
  end

  def category_dir
    @category_dir ||= "#{DEST_DIR}/#{category}"
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
    "#{@id}, #{title}"
  end

  def to_extra_s
    "#{@id}, #{title}, #{destination_file_path}"
  end

  def to_a
    data
  end

  def self.clear_temp_dir!
    FileUtils.rm_rf("#{Article::DOWNLOAD_DIR}/.", secure: true)
  end

  def delete_destination_file!
    return false unless File.exist?(destination_file_path)

    File.delete(destination_file_path)
  end

  def delete_text_file!
    return false unless File.exist?(text_file_path)

    File.delete(text_file_path)
  end

  def pdf_reader
    @pdf_reader ||= fetch_pdf_reader
  end

  def fetch_pdf_reader
    return nil unless File.exist?(destination_file_path)

    begin
      PDF::Reader.new(destination_file_path)
    rescue StandardError
      nil
    end
  end

  def page_count
    @page_count ||= pdf_reader&.page_count || -1
  end

  def first_page_text
    @first_page_text ||= pdf_reader&.pages&.first&.text
  end

  def text_file_path
    File.basename(destination_file_path) + '.pdf'
  end

  def save_text_file!
    delete_text_file!

    File.open(text_file_path, 'w') { |file| file.write(first_page_text) }
  end

  def maybe_correct?
    c_first_page_text = comparable_string(first_page_text)
    c_publication = comparable_string(publication)

    c_first_page_text.include?(c_publication) && c_first_page_text.include?(year)
  end

  def maybe_wrong?
    !maybe_correct?
  end

  def comparable_string(str)
    str.to_s.gsub(/[^0-9A-Za-z]/, '').downcase
  end

  def file_size
    File.size(destination_file_path)
  end

  def title_matching_rate
    title_words = title.downcase.split(' ')

    page_text = first_page_text.downcase

    intersection_words = []
    title_words.each do |word|
      next unless page_text.include? word

      intersection_words << word
    end

    intersection_words.count / title_words.count.to_f
  end

  def to_extra_a
    item = data
    item << destination_file_path
    item << page_count
  end

  def image_pdf?
    first_page_text.length < 250
  end
end
