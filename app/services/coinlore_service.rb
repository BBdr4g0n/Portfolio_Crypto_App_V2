require 'net/http'
require 'json'

class CoinloreService
  BASE_URI = 'https://api.coinlore.net/api'

  def get_tokens_list
    get_cached_tokens_list ||= fetch_tokens_list
  end

  def get_cached_tokens_list
    list = Rails.cache.read('coinlore_tokens_list')
    if list
      Rails.logger.info "Retrieved #{list.size} tokens from cache"
    else
      Rails.logger.info "Cache is empty"
    end
    return list
  end

  def fetch_tokens_list
    Rails.cache.fetch('coinlore_tokens_list', expires_in: 12.hours) do
      Rails.logger.info "Fetching tokens list from API"
      list = []
      offset = 0
      limit = 100
      total_tokens = 12833  # Total number of coins from Coinlore API

      while offset < total_tokens
        uri = URI("#{BASE_URI}/tickers/?start=#{offset}&limit=#{limit}")
        response = Net::HTTP.get_response(uri)

        if response.is_a?(Net::HTTPSuccess)
          list += JSON.parse(response.body)['data']
        else
          Rails.logger.error("Failed to fetch tokens list from Coinlore API")
          return []
        end

        offset += limit
      end

      Rails.logger.info "Caching #{list.size} tokens"
      list
    end
  end

  def find_tokens_by_symbol(symbol)
    get_cached_tokens_list.nil? ? tokens = fetch_tokens_list : tokens = get_cached_tokens_list
    tokens.select { |token| token['symbol'] == symbol.upcase }
  end

  def get_current_price_by_symbol(symbol)
    tokens = find_tokens_by_symbol(symbol)

    if tokens.size == 1
      current_price = tokens[0]["price_usd"].to_f
    elsif tokens.size > 1
      current_price = 'Multiple prices found'
    else
      current_price = 'Price not found'
    end

    return current_price
  end
end
