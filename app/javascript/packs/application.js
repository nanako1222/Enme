import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

// jQueryをグローバル（window）に即座に登録
import jQuery from "jquery"
window.$ = window.jQuery = jQuery;

import "popper.js"
import "bootstrap"
import "../stylesheets/application"
import '@fortawesome/fontawesome-free/js/all'

// 最後に自分のJSを読み込む
import "./area.js"

Rails.start()
ActiveStorage.start()
