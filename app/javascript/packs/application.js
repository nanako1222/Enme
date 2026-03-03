import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

// jQueryを先に読み込み、グローバルで使えるようにする
import jQuery from "jquery"
window.$ = window.jQuery = jQuery

// その後にBootstrapを読み込む
import "popper.js"
import "bootstrap"

import "../stylesheets/application"
import '@fortawesome/fontawesome-free/js/all'

Rails.start()
ActiveStorage.start()
