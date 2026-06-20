class SeedStatesAndAreas < ActiveRecord::Migration[6.1]
  def up
    return if State.exists?

    states_data = {
      "大阪府" => ["大阪市", "北河内", "中河内", "豊能", "三島", "泉北", "泉南", "南河内"],
      "兵庫県" => ["但馬", "神戸市", "北播磨", "中播磨", "東播磨", "西播磨", "丹波", "阪神北", "阪神南", "淡路"],
      "京都府" => ["丹後", "中丹", "南丹", "京都市", "山城"],
      "滋賀県" => ["湖北", "湖東", "湖西", "東近江", "大津市", "湖南", "甲賀"],
      "和歌山県" => ["和歌山市", "高野山", "紀中", "熊野", "白浜・串本"],
      "奈良県" => ["奈良市", "生駒・信貴・斑鳩・葛城", "山の辺・飛鳥・橿原・宇陀", "吉野路"]
    }

    states_data.each do |state_name, area_names|
      state = State.find_or_create_by!(state: state_name)
      area_names.each do |a_name|
        state.areas.find_or_create_by!(area: a_name)
      end
    end
  end

  def down
    # データ削除はしない
  end
end
