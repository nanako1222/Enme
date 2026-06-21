class AreasController < ApplicationController
  def index
    state_id = params[:state_id]
    type = params[:type]

    if type == "search"
      areas = state_id.present? ? Area.where(state_id: state_id) : []
      options = "<option value=''>すべてのエリア</option>"
    else
      areas = state_id.present? ? Area.where(state_id: state_id) : []
      options = "<option value=''>選択してください</option>"
    end

    areas.each do |area|
      name = area.try(:area) || area.try(:name) || "名称未設定"
      options += "<option value='#{area.id}'>#{name}</option>"
    end

    render html: options.html_safe
  end
end
