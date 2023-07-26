require 'optparse'

# rake downloaded_csv -- -f article_list.csv
task :downloaded_csv do
  require_relative 'downloaded_csv_builder'
  options = {
    input_file: 'article_list.csv'
  }
  opts = OptionParser.new
  opts.banner = 'Usage: rake report [options]'
  opts.on('-f', '--f FILENAME', 'Input csv file name') { |input_file| options[:input_file] = input_file }
  args = opts.order!(ARGV) {}
  opts.parse!(args)

  puts '----------------------------------------------------'
  puts 'Start building valid csv for downloaded files...'
  puts '----------------------------------------------------'

  DownloadedCsvBuilder.new(options[:input_file]).call
end

# rake report -- -f article_list.csv
task :report do
  require_relative 'reporter'
  options = {
    input_file: 'article_list.csv'
  }
  opts = OptionParser.new
  opts.banner = 'Usage: rake report [options]'
  opts.on('-f', '--f FILENAME', 'Input csv file name') { |input_file| options[:input_file] = input_file }
  args = opts.order!(ARGV) {}
  opts.parse!(args)

  puts '--------------------------------'
  puts 'Start reporting...'
  puts '--------------------------------'

  Reporter.new(options[:input_file]).call
end

# rake download -- -f article_list.csv
task :download do
  require 'csv'
  require_relative 'csv_downloader'

  options = {
    input_file: 'article_list.csv'
  }
  opts = OptionParser.new
  opts.banner = 'Usage: rake download [options]'
  opts.on('-f', '--f FILENAME', 'Input csv file name') { |input_file| options[:input_file] = input_file }
  args = opts.order!(ARGV) {}
  opts.parse!(args)

  puts '--------------------------------'
  puts 'Start downloading...'
  puts '--------------------------------'

  CsvDownloader.new(options[:input_file], 24).call
end

# rake csv -- -f article_list.csv -p ScienceDirect -c agriculture -u https://www.sciencedirect.com/
task :csv do
  require_relative 'scraper'
  require_relative 'category'

  options = {
    url: 'https://www.sciencedirect.com/search?show=100&date=2003-2023&articleTypes=FLA&accessTypes=openaccess',
    category: 'agriculture',
    output_file: 'article_list.csv',
    publication: 'ScienceDirect'
  }
  opts = OptionParser.new
  opts.banner = 'Usage: rake csv [options]'
  opts.on('-u', '--u URL', 'URL for article list') { |url| options[:url] = url }
  opts.on('-f', '--f FILENAME', 'Output csv filename') { |output_file| options[:output_file] = output_file }
  opts.on('-c', '--c CATEGORY', 'Category') { |category| options[:category] = category }
  opts.on('-p', '--p PUBLICATION_TITLE', 'Publication title') { |publication| options[:publication] = publication }
  args = opts.order!(ARGV) {}
  opts.parse!(args)

  puts '--------------------------------'
  puts 'Start building csv...'
  puts '--------------------------------'

  base_url = options[:url]

  Category::ALL.each do |category|
    category[:publications].each do |publication|
      (2003..2023).each do |year|
        url = base_url + "&subjectAreas=#{category[:id]}&publicationTitles=#{publication[:id]}&years=#{year}"
        while url
          puts "Processing url: #{url}"

          context = Scraper.new(url, year, publication[:title], category[:title], options[:output_file]).scrape
          sleep(3)
          puts '--------------------------------'
          if context && (url = context.next_url)
            puts 'Next!'
          else
            url = false
            puts "#{category[:title]} #{publication[:title]} #{year} Done!"
          end
        end
      end
    end
  end
end
