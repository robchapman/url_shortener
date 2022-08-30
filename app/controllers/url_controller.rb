# frozen_string_literal: true

class URLController < ActionController::API
  SHORT_URL_LENGTH = 5
  SHORT_URL_CHAR_SET = ('a'..'z').to_a

  before_action :load_url_cache, only: [:shorten]

  # Recieves a shortened url string, redirects to the matching url,
  # if none exists return no_content
  def redirect
    original_url = Rails.cache.read(url_param)
    if original_url
      redirect_to with_protocol(original_url), status: :moved_permanently
    else
      render status: :no_content
    end
  end

  # Recieves a full length url, checks if it has already been stored in the cache
  # if so, it will return the matching short url, if not a new one is generated,
  # stored and returned.
  def shorten
    # TODO: Vailidate url param
    url = trim_url(url_param)
    existing_short_url = retrieve_short_url(url)
    if existing_short_url
      render_url_payload(existing_short_url, url)
    else
      new_short_url = create_new_short_url(url)
      if new_short_url
        render_url_payload(new_short_url, url)
      else
        render status: :bad_request
      end
    end
  end

  private

  def url_param
    params.require(:url)
  end

  def trim_url(url)
    url = url.split('https://').last
    url = url.split('http://').last
    url.split(/^www\./).last
  end

  def with_protocol(url)
    "http://#{url}"
  end

  # Loads url cache items as array
  # TODO: When using a DB, pull in batches
  def load_url_cache
    @url_cache = []
    index = 0
    loop do
      key = Rails.cache.read(index)
      break unless key

      @url_cache << { "#{key}": Rails.cache.read(key) }
      index += 1
    end
  end

  def retrieve_short_url(url)
    short_url = nil
    @url_cache.each do |hash|
      if url == hash.values.first
        short_url = hash.keys.first
        break
      end
    end
    short_url
  end

  def create_new_short_url(url)
    short_url = generate_short_url(url)
    cache_new_url(short_url, url) ? short_url : nil
  end

  # TODO: For larger db, increment length when all in use
  # or could repace with a meaningful short string
  def generate_short_url(_url)
    short_urls = @url_cache.map { |hash| hash.keys.first }
    new_short_url = random_string(SHORT_URL_LENGTH)
    new_short_url = random_string(SHORT_URL_LENGTH) while short_urls.include?(new_short_url)
    new_short_url
  end

  # TODO: extract into helper file and test
  def random_string(size)
    SHORT_URL_CHAR_SET
      .flat_map { |item| Array.new((size / SHORT_URL_CHAR_SET.size) + 1, item) }
      .shuffle[0, size].join
  end

  # TODO: ideally would roll back cache write if first fails
  def cache_new_url(short_url, url)
    Rails.cache.write(short_url, url) && Rails.cache.write(@url_cache.size, short_url)
  end

  def render_url_payload(short_url, url)
    render json: {
      "short_url": short_url,
      "url": with_protocol(url)
    }, status: :ok
  end
end
