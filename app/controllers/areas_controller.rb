class AreasController < ApplicationController
  def index
    # 送られてきた都道府県IDに紐づく地域を取得
    @areas = Area.where(state_id: params[:state_id])
    
    # セレクトボックスの中身（HTML）を文字列として作成
    options = "<option value=''>選択してください</option>"
    @areas.each do |area|
      options += "<option value='#{area.id}'>#{area.name}</option>"
    end

    # HTML形式で文字列のみを返す（ビューファイルを使わない設定）
    render inline: options, layout: false
  end
end
