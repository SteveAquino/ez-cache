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
      get :index, params: {q: 'search query'}
      expect(response.status).to eq(200)

      request.env["HTTP_IF_NONE_MATCH"] = response.headers['ETag']
      get :index, params: {q: 'search query'}
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

  describe ".ez_cache_action"

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
  end

  describe "#params_cache_key"
  describe "#header_cache_key"
end
