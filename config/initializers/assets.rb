# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')
# Ensure Font Awesome webfonts are resolved to logical paths like /assets/fa-brands-400.woff2
Rails.application.config.assets.paths << Rails.root.join('node_modules/@fortawesome/fontawesome-free/webfonts')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
Rails.application.config.assets.precompile += %w[
  fa-solid-900.woff2
  fa-regular-400.woff2
  fa-brands-400.woff2
  fa-v4compatibility.woff2
]
