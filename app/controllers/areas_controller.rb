class AreasController < ApplicationController
  def index
    # state_idが空の場合やデータがない場合でもエラーにならないようにする
    state_id = params[:state_id]
    @areas = state_id.present? ? Area.where(state_id: state_id) : []
    
    options = "<option value=''>選択してください</option>"
    @areas.each do |area|
      # カラム名が 'area' か 'name' か不明なため、両方に対応
      name = area.try(:area) || area.try(:name) || "名称未設定"
      options += "<option value='#{area.id}'>#{name}</option>"
    end

    # HTMLとして安全に返却
    render html: options.html_safe
  end
end
