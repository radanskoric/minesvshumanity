// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

Turbo.StreamActions.versioned_replace = function () {
  let payloadVersion = parseInt(this.templateContent.children[0].dataset.version)
  let pageVersion = parseInt(this.targetElements[0].dataset.version)
  if (payloadVersion > pageVersion) {
    Turbo.StreamActions.replace.bind(this)()
  }
}
