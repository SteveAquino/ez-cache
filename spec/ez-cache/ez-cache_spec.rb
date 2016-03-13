require 'rails_helper'

describe DummyController, type: :controller do
  describe "GET index" do
    before(:each) { get :index }

    it "returns an ETag header" do
      expect(response.headers['ETag'].present?).to eq(true)
    end

    it "returns a 304 on subsequent requests" do
      request.env["HTTP_IF_NONE_MATCH"] = response.headers['ETag']
      get :index
      expect(response.status).to eq(304)
    end

    it "caches with params" do
      request.env["HTTP_IF_NONE_MATCH"] = response.headers['ETag']
      get :index, params: {page: 'search query'}
      expect(response.status).to eq(200)

      request.env["HTTP_IF_NONE_MATCH"] = response.headers['ETag']
      get :index, params: {page: 'search query'}
      expect(response.status).to eq(304)
    end
  end

  describe "GET protected" do
    before(:each) { get :protected }

    it "returns an ETag header" do
      expect(response.headers['ETag'].present?).to eq(true)
    end

    it "returns a 304 on subsequent requests" do
      request.env["HTTP_IF_NONE_MATCH"] = response.headers['ETag']
      get :protected
      expect(response.status).to eq(304)
    end

    it "caches with headers" do
      request.env['HTTP_IF_NONE_MATCH'] = response.headers['ETag']
      request.env['HTTP_AUTHORIZATION'] = 'Bearer sekret'
      get :protected
      expect(response.status).to eq(200)

      request.env['HTTP_IF_NONE_MATCH'] = response.headers['ETag']
      request.env['HTTP_AUTHORIZATION'] = 'Bearer sekret'
      get :protected
      expect(response.status).to eq(304)
    end
  end

  describe "GET show" do
    before(:each) { get :show, params: {id: '123'} }

    it "returns an ETag header" do
      expect(response.headers['ETag'].present?).to eq(true)
    end

    it "returns a 304 on subsequent requests" do
      request.env["HTTP_IF_NONE_MATCH"] = response.headers['ETag']
      get :show, params: {id: '123'}
      expect(response.status).to eq(304)
    end

    it "caches with URL params" do
      request.env['HTTP_IF_NONE_MATCH'] = response.headers['ETag']
      get :show, params: {id: '456'}
      expect(response.status).to eq(200)

      request.env['HTTP_IF_NONE_MATCH'] = response.headers['ETag']
      get :show, params: {id: '456'}
      expect(response.status).to eq(304)
    end
  end

  describe ".ez_cache_action" do
    it 'calls .before_action with a given action name' do
      expect(controller.class).to receive(:before_action).with(only: [:index, :show])
      controller.class.ez_cache_action [:index, :show], 'users/index', if: :something_true?
    end

    it 'converts a single action name into an array' do
      expect(controller.class).to receive(:before_action).with(only: [:index])
      controller.class.ez_cache_action :index, 'users/index'
    end
  end

  describe "#delta_cache_key" do
    it "caches a new delta key" do
      key = controller.delta_cache_key('users/index')
      expect(controller.delta_cache_key('users/index')).to eq(key)
    end

    it "can be reset by clearing the base key" do
      key = controller.delta_cache_key('users/index')
      Rails.cache.delete('users/index')
      expect(controller.delta_cache_key('users/index')).to_not eq(key)
    end

    describe 'with a parameterized key' do
      let(:params) { ActionController::Parameters.new(id: 1) }

      it 'builds a cache key with parameter values' do
        key = controller.delta_cache_key('users/show/:id', params)
        expect(controller.delta_cache_key('users/show/1')).to eq(key)
      end

      it "can be reset with a parameterized key" do
        key = controller.delta_cache_key('users/show/:id', params)
        Rails.cache.delete('users/show/1')
        expect(controller.delta_cache_key('users/show/1')).to_not eq(key)
      end
    end
  end

  describe "#params_cache_key" do
    let(:params)  { ActionController::Parameters.new id: 1 }
    before(:each) { allow(controller).to receive(:params).and_return(params) }

    it 'builds a cache key from request params' do
      expect(controller.params_cache_key([:id])).to eq('{"id"=>1}')
    end
  end

  describe "#header_cache_key" do
    before(:each) { request.env["HTTP_AUTHORIZATION"] = "Bearer 123" }

    it 'builds a cache key from request headers' do
      expect(controller.header_cache_key([:authorization])).to eq('{"authorization"=>"Bearer 123"}')
    end
  end
end
