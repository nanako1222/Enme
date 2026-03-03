import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

import "jquery"
import "popper.js"
import "bootstrap"

import "../stylesheets/application"
import '@fortawesome/fontawesome-free/js/all'

Rails.start()
ActiveStorage.start()

// jQueryをグローバルに展開（これが無いとプルダウンが動きません）
window.$ = window.jQuery = require('jquery');
