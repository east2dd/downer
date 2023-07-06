require 'selenium-webdriver'
require 'csv'
require 'interactor'
require 'open-uri'
require 'puppeteer'

class DownloadArticlePdf
  include Interactor

  def call
    ::Puppeteer.launch(headless: false) do |browser|
      context.article_list.each do |article|
        next if article[0] == 'id'

        id = article[0]
        url = article[1]
        category = article[4].downcase

        pdf_file_path = "#{category}/#{id}.pdf"

        next if File.exist?(pdf_file_path)

        ensure_download_directory(category)
        download_pdf(browser, url, pdf_file_path, article)
      end
    end
  end

  private

  def ensure_download_directory(category)
    current_directory = File.dirname(File.expand_path(__FILE__))
    directory_path = current_directory + '/' + category

    # Check if the directory exists
    Dir.mkdir(directory_path) unless Dir.exist?(directory_path)

    directory_path
  end

  def download_pdf(browser, url, pdf_file_path, article)
    article_id = article[0]
    article_title = article[2]
    puts "Downloading pdf for: #{article_id} #{article_title}"
    page = browser.new_page
    page.goto url, wait_until: 'networkidle0'

    # Wait for the page to fully load (add appropriate waits if needed)
    sleep(0.5)
    page.evaluate('window.scrollTo(0, document.body.scrollHeight)')
    sleep(1)
    page.add_style_tag(content: '.ReferenceLinks, #banner .crossmark-button, #banner svg, .RelatedContent, .related-content-links { display: none !important; }')
    page.add_style_tag(content: '@media print { .publication-brand, .publication-cover { display: block !important; } }')
    # page.add_style_tag(content: '@media print { #body, .bibliography { page-break-before: always; }}')

    page.evaluate <<~JS
      const keywords = document.querySelector('.Keywords');
      const abstracts = document.querySelector('#abstracts');
      keywords.parentNode.insertBefore(keywords, abstracts)

      const header = document.querySelector('header');
      if (header) {
        header.remove();
      }

      const showMoreBtn = document.getElementById('show-more-btn');
      if (showMoreBtn) {
        showMoreBtn.click();
        showMoreBtn.remove();
      }

      const bannerOptions = document.querySelector('#banner .banner-options');
      if (bannerOptions) {
        bannerOptions.remove();
      }

      const relatedContent = document.querySelector('.RelatedContent');
      if (relatedContent) {
        relatedContent.remove();
      }

      const articleIdentifierLinks = document.querySelector('.ArticleIdentifierLinks');
      if (articleIdentifierLinks) {
        articleIdentifierLinks.remove();
      }

      const licenseInfo = document.querySelector('.LicenseInfo');
      if (licenseInfo) {
        licenseInfo.remove();
      }

      const footer = document.querySelector('footer');
      if (footer) {
        footer.remove();
      }

      const issueNavigation = document.getElementById('issue-navigation');
      if(issueNavigation) {
        issueNavigation.remove();
      }

      const citedBy = document.getElementById('section-cited-by');
      if(citedBy) {
        citedBy.remove();
      }
    JS

    pdf_options = {
      path: pdf_file_path,
      format: 'A3',
      margin: {
        top: '20px',
        right: '20px',
        bottom: '20px',
        left: '20px'
      }
    }

    # Print the page as PDF
    page.pdf(pdf_options)

    context.download_count += 1
    puts "Pdf saved successfully: #{article_id}.pdf"
    puts "Download count: #{context.download_count}"
    puts '----------------------------------------------------------------'

    page.close
  end
end
