class Restaurant::CompaniesController < ApplicationController
  def cities_select
    if request.xhr?
      render partial: 'areas', locals: {ms_pref_id: params[:ms_pref_id]}
    end
  end
end