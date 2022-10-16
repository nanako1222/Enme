class Customer::CompaniesController < ApplicationController
  def cities_select
    if request.xhr?
      render partial: 'cities', locals: {ms_pref_id: params[:ms_pref_id]}
    end
  end
end
