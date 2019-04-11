# frozen_string_literal: true

require 'rails_helper'

describe 'As a user' do
  context 'After I send a group survey', :vcr do
    before :each do
      @user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      @restaurant_1 = create(:restaurant)
      @restaurant_2 = create(:restaurant)
      @restaurant_3 = create(:restaurant)
      @restaurant_4 = create(:restaurant)

      @survey = create(:survey, user: @user)
      @survey_2 = create(:survey, user: @user)

      @phone_1 = create(:phone_number, survey: @survey)
      @phone_2 = create(:phone_number, survey: @survey)
      @phone_3 = create(:phone_number, survey: @survey)
      @phone_4 = create(:phone_number, survey: @survey, digits: '+12223334444')

      @sr_1 = @survey.survey_restaurants.create(restaurant: @restaurant_1)
      @sr_2 = @survey.survey_restaurants.create(restaurant: @restaurant_2)
      @sr_3 = @survey.survey_restaurants.create(restaurant: @restaurant_3)

      url = "http://api.bit.ly/v3/shorten?apiKey=#{ENV['BITLY_API_KEY']}&login=#{ENV['BITLY_LOGIN']}&longUrl=https://localhost:3000/surveys/#{@survey.id}"
      filename = 'bitly_response.json'
      stub_get_json(url, filename)
    end

    it 'I can see the survey results page' do
      visit survey_path(@survey)

      expect(page).to have_content('Survey results! Watch them roll in...')
      expect(page).to have_content('Survey Status: Active')
      expect(page).to have_content('Total Votes Received:')

      expect(page).to have_content(@restaurant_1.name.to_s)
      expect(page).to have_content(@restaurant_2.name.to_s)
      expect(page).to have_content(@restaurant_3.name.to_s)
      expect(page).to_not have_content(@restaurant_4.name.to_s)

      expect(page).to have_css('.survey-restaurant', count: 3)

      within(".survey-restaurant-#{@sr_1.id}") do
        expect(page).to have_content(@restaurant_1.name.to_s)
        expect(page).to have_content('Votes received:')
      end

      expect(page).to have_button('End Survey Now')
    end

    it 'page updates with votes' do
      @vote1 = create(:vote, survey: @survey, phone_number: @phone_1, survey_restaurant: @sr_1)
      @vote2 = create(:vote, survey: @survey, phone_number: @phone_2, survey_restaurant: @sr_1)
      @vote3 = create(:vote, survey: @survey, phone_number: @phone_3, survey_restaurant: @sr_3)

      visit survey_path(@survey)

      expect(page).to have_content('Survey Status: Active')
      expect(page).to have_content('Total Votes Received:')

      within(".survey-restaurant-#{@sr_1.id}") do
        expect(page).to have_content('Votes received:')
      end

      within(".survey-restaurant-#{@sr_2.id}") do
        expect(page).to have_content('Votes received:')
      end

      within(".survey-restaurant-#{@sr_3.id}") do
        expect(page).to have_content('Votes received:')
      end
    end

    it 'I can end the survey by button', :vcr do
      @vote1 = create(:vote, survey: @survey, phone_number: @phone_1, survey_restaurant: @sr_1)
      @vote2 = create(:vote, survey: @survey, phone_number: @phone_2, survey_restaurant: @sr_3)
      @vote3 = create(:vote, survey: @survey, phone_number: @phone_3, survey_restaurant: @sr_3)

      visit survey_path(@survey)

      expect(page).to have_content('Survey results! Watch them roll in...')
      expect(page).to have_content('Survey Status: Active')
      expect(page).to have_content('Total Votes Received:')

      within(".survey-restaurant-#{@sr_1.id}") do
        expect(page).to have_content('Votes received:')
      end

      within(".survey-restaurant-#{@sr_3.id}") do
        expect(page).to have_content('Votes received:')
      end

      expect(page).to have_button('End Survey Now')

      click_button 'End Survey Now'
      visit survey_path(@survey)

      expect(current_path).to eq(survey_path(@survey))

      expect(page).to have_content('Survey Status: Closed')
      expect(page).to have_content('Total Votes Received:')

      expect(page).to have_content("#{@restaurant_3.name} received the most votes!")

      expect(page).to have_button('Take Me There!')
      expect(page).to have_button('Start Another Survey')

      expect(page).to_not have_button('End Survey Now')
    end
  end
end
