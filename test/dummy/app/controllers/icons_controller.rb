# frozen_string_literal: true

class IconsController < ActionController::Base
  def show
    render inline: "<%= kiso_icon_tag('lucide:check') %>"
  end
end
