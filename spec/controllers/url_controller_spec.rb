# frozen_string_literal: true

RSpec.describe URLController, type: :controller do
  let(:short_url) { 'short' }
  let(:long_url) { 'http://test.com' }
  let(:stripped_url) { 'test.com' }
  after(:each) { Rails.cache.clear }

  describe 'GET /:url' do
    context 'when there is a matching url stored' do
      it 'redirects to that url' do
        Rails.cache.write(short_url, long_url)
        get :redirect, params: { url: short_url }
        expect(response).to redirect_to(long_url)
      end
    end

    context 'when there is no matching url stored' do
      it 'returns no content' do
        get :redirect, params: { url: short_url }
        expect(response).to have_http_status(:no_content)
      end
    end
  end

  describe 'POST /' do
    context 'when a url is posted' do
      it 'returns a String' do
        post :shorten, params: { url: long_url }
        expect(JSON.parse(response.body)['short_url']).to be_a(String)
      end

      it 'returns a short string' do
        post :shorten, params: { url: long_url }
        expect(JSON.parse(response.body)['short_url'].length).to eq(5)
      end

      it 'returns the long url' do
        post :shorten, params: { url: long_url }
        expect(JSON.parse(response.body)['url']).to eq(long_url)
      end

      it 'should return a success' do
        post :shorten, params: { url: long_url }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the url in request has different protocols' do
      ['http://', 'https://.', 'http://www.', 'https://www.', 'www.'].each do |prefix|
        it "#{prefix} - returns the url the same" do
          long_url = prefix + stripped_url
          post :shorten, params: { url: long_url }
        end
      end
    end

    context 'when the same url is posted' do
      it 'returns the same short url' do
        post :shorten, params: { url: "https://#{stripped_url}" }
        first_response_short_url = JSON.parse(response.body)['short_url']
        post :shorten, params: { url: "https://www.#{stripped_url}" }
        expect(JSON.parse(response.body)['short_url']).to eq(first_response_short_url)
      end
    end
  end
end
