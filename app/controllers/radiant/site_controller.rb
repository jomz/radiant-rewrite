require_dependency "radiant/application_controller"

module Radiant
  class SiteController < ApplicationController
    layout 'application'

    def show_page
      url = params[:url]
      if url === Array
        url = url.join('/')
      else
        url = url.to_s
      end
      if @page = find_page(url)
        process_page(@page)
        # set_cache_control
        # @performed_render ||= true
      else
        render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found
      end
    rescue Radiant::Page::MissingRootPageError
      redirect_to welcome_url
    end

    private

    def find_page(url)
      Radiant::Page.find_by_path(url)
    end

    def process_page(page)
      page.process(request, response)
    end
  end
end
