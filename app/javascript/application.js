// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import 'jquery.oembed';
import 'jQuery.XDomainRequest';
import 'bootstrap';

import 'feedback_form';
import Embed from 'purl_embed';
import jQuery from 'jquery'

window.addEventListener("load", () => {
  Embed.init(jQuery)
})

import('analytics'); // Dynamically import, so that a content-blocker doesn't break the scripts