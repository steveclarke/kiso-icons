# frozen_string_literal: true

class IconsController < ActionController::Base
  layout "application"

  def index
    @icons = [
      {set: "lucide", name: "house", label: "Lucide"},
      {set: "heroicons", name: "home", label: "Heroicons"},
      {set: "mdi", name: "home", label: "Material Design"},
      {set: "tabler", name: "home", label: "Tabler"},
      {set: "ph", name: "house", label: "Phosphor"},
      {set: "ri", name: "home-line", label: "Remix Icon"},
      {set: "bi", name: "house", label: "Bootstrap Icons"},
      {set: "carbon", name: "home", label: "Carbon"},
      {set: "ion", name: "home-outline", label: "Ionicons"},
      {set: "octicon", name: "home-16", label: "Octicons"}
    ]
  end

  def show
    render inline: "<%= kiso_icon_tag('lucide:check') %>"
  end
end
