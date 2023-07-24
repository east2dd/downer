require 'interactor'
require 'puppeteer'
require 'action_view'
require 'launchy'

CURRENT_DIR = File.dirname(File.expand_path(__FILE__))

class DownloadArticlePdf
  include Interactor
  include ActionView::Helpers::DateHelper

  def call
    context.starts_at = Time.now
    context.total_count = context.article_list.count
    context.total_download_count = 0

    ::Puppeteer.launch(headless: false, args: ['--javascript-harmony']) do |browser|
      context.article_list.each do |article|
        next if article[0] == 'id'

        id = article[0]
        url = article[1]
        publication = article[4]
        category = article[5]

        pdf_file_path = "#{CURRENT_DIR}/downloads/#{category}/#{publication}/#{id}.pdf"

        if File.exist?(pdf_file_path)
          context.total_download_count += 1
          next
        end

        ensure_download_directory(category, publication)
        download_pdf(browser, url, pdf_file_path, article)
      end
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

  def download_pdf(browser, url, pdf_file_path, article)
    article_id = article[0]
    article_title = article[2]
    article_year = article[3]
    article_publication = article[4]

    puts "v Downloading pdf: #{article_id}, #{article_year}, #{article_publication}, #{article_title}"
    page = browser.new_page
    user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.5735.198 Safari/537.36'
    page.set_user_agent(user_agent)

    begin
      page.goto url, wait_until: 'networkidle0'
    rescue StandardError => e
      page.close
      raise e
    end

    page.add_style_tag(content: '.ReferenceLinks, #banner .crossmark-button, #banner svg, .RelatedContent, .related-content-links { display: none !important; }')
    page.add_style_tag(content: '#body figure img { max-width: 100% !important; padding: 1rem 0!important; }')
    page.add_style_tag(content: 'header { display: none !important;}')
    page.add_style_tag(content: '.article-wrapper > div:first-child,  article-wrapper > div:last-child { display: none !important;}')
    page.add_style_tag(content: '@media print { .publication-brand, .publication-cover { display: block !important; } }')
    page.add_style_tag(content: '@media print { thead { display: table-row-group } }')

    # page.add_style_tag(content: '@media print { #body, .bibliography { page-break-before: always; }}')
    # Wait for the page to fully load (add appropriate waits if needed)
    sleep(0.5)
    page.evaluate('window.scrollTo(0, document.body.scrollHeight)')

    pdf_embed_element_exists = page.evaluate("() => {
      return document.querySelector('.PdfEmbed') !== null;
    }")

    if pdf_embed_element_exists
      puts 'BREAKING: Found embed pdf, ignoring and moving next!'
      page.close
      return false
    end

    evaluate_general_script(page)
    evaluate_image_script(page)

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
    context.total_download_count += 1

    puts "+ Pdf saved successfully: #{pdf_file_path}"
    print_download_summary
    page.close
  end

  def print_download_summary
    time_in_words = distance_of_time_in_words(context.starts_at, Time.now)
    hours = (Time.now.to_i - context.starts_at.to_i).to_f / 3600.0
    speed = (context.download_count.to_f / hours).to_i
    download_percent = (context.total_download_count / context.total_count.to_f) * 100
    puts ''
    puts "  ~ Download percent: #{download_percent.round(2)}% (#{context.total_download_count} / #{context.total_count})"
    puts "  ~ Download speed: #{speed}/h (#{context.download_count} downloaded, #{time_in_words} ellapsed)"
    puts ''
    puts '--------------------------------'
  end

  def evaluate_general_script(page)
    page.evaluate <<~JS
      const keywords = document.querySelector('.Keywords');
      const abstracts = document.querySelector('#abstracts');
      if(keywords) {
        keywords.parentNode.insertBefore(keywords, abstracts);
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
  end

  def evaluate_image_script(page)
    page.evaluate <<~JS
      const bodyElement = document.querySelector('#body'); // Replace with the ID or selector of your <div> element
      const figureElements = bodyElement.querySelectorAll('figure'); // Select all figure elements on the page

      for (const figureElement of figureElements) {
        const imgElement = figureElement.querySelector('span img');
        const olElement = figureElement.querySelector('span ol');

        if (imgElement && olElement) {
          const liElements = olElement.querySelectorAll('li');

          if (liElements && liElements.length > 0) {
            const aElement = liElements[0].querySelector('a');
            const href = aElement.getAttribute('href');

            imgElement.setAttribute('src', '');
            imgElement.setAttribute('src', href);
            imgElement.setAttribute('height', 'auto');
            imgElement.setAttribute('width', 'auto');

            olElement.remove();
          }
        }
      }
    JS

    page.wait_for_function('() => {
      const images = Array.from(document.querySelectorAll("figure img"));
      return images.every(img => img.complete && img.naturalHeight !== 0);
    }')
  end
end
