# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "jquery", to: "https://ga.jspm.io/npm:jquery@3.6.1/dist/jquery.js"
pin "bootstrap", to: "https://ga.jspm.io/npm:bootstrap@5.2.3/dist/js/bootstrap.esm.js"
pin "@popperjs/core", to: "https://ga.jspm.io/npm:@popperjs/core@2.11.6/lib/index.js"
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin 'feedback_form'
pin "ace-builds", to: "https://ga.jspm.io/npm:ace-builds@1.16.0/src-noconflict/ace.js"