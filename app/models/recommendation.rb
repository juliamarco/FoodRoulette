# frozen_string_literal: true

class Recommendation
  attr_reader :name,
              :address,
              :price_range,
              :cuisine,
              :rating,
              :distance,
              :restaurant_id,
              :database_id,
              :image_url,
              :url
  def initialize(data, restaurant)
    @name = data[:name]
    @address = "#{data[:location][:address1]} #{data[:location][:address2]} #{data[:location][:city]}, #{data[:location][:state]} #{data[:location][:zip_code]}"
    @price_range = data[:price]
    @cuisine = data[:categories].first[:title]
    @rating = data[:rating]
    @distance = (data[:distance] / 1609.344).round(2)
    @restaurant_id = restaurant.yelp_id
    @database_id = restaurant.id
    @image_url = data[:image_url]
    @url = data[:url]
  end
end
