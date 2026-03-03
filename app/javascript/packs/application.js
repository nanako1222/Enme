import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

// jQueryを最優先で読み込み、どこからでも使えるように固定する
import jQuery from "jquery"
window.$ = window.jQuery = jQuery

// ライブラリの読み込み
import "popper.js"
import "bootstrap"

// スタイルシートと個別のJS（ここが地域連動に重要！）
import "../stylesheets/application"
import '@fortawesome/fontawesome-free/js/all'
import './area.js' 

Rails.start()
ActiveStorage.start()
