require 'optparse'

# rake download -- -f article_list.csv
task :download do
  require 'csv'
  require_relative 'downloader'

  options = {
    input_file: 'article_list.csv'
  }
  opts = OptionParser.new
  opts.banner = 'Usage: rake download [options]'
  opts.on('-f', '--f FILENAME', 'Input csv file name') { |input_file| options[:input_file] = input_file }
  args = opts.order!(ARGV) {}
  opts.parse!(args)

  puts opts
  puts 'Start downloading...'
  puts '--------------------------------'

  article_list = CSV.read(options[:input_file])
  Downloader.new(article_list).download
end

# rake csv -- -f article_list.csv -p ScienceDirect -c agriculture -u https://www.sciencedirect.com/
task :csv do
  require_relative 'scraper'

  options = {
    url: 'https://www.sciencedirect.com/search?show=100&qs=agriculture&date=2003-2023&articleTypes=FLA&lastSelectedFacet=articleTypes&accessTypes=openaccess&offset=900',
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

  puts opts
  puts 'Start building csv...'
  puts '--------------------------------'

  url = options[:url]

  while url
    puts "Processing url: #{url}"

    context = Scraper.new(url, options[:publication], options[:category], options[:output_file]).scrape
    sleep(3)

    puts '--------------------------------'
    url = context.next_url

    if url
      puts 'Next!'
    else
      puts 'Done!'
    end
  end
end
