# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "jquery", to: "https://ga.jspm.io/npm:jquery@3.6.1/dist/jquery.js"
pin "bootstrap", to: "https://ga.jspm.io/npm:bootstrap@5.2.3/dist/js/bootstrap.esm.js"
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/preview_controllers", under: "preview_controllers"
# Preview is a separate application to avoid loading ace-builds for every page
pin 'preview_application'
pin 'feedback_form'
pin "ace-builds", to: "https://ga.jspm.io/npm:ace-builds@1.16.0/src-noconflict/ace.js"
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
