class PagesController < ApplicationController
  def terms; end

  def privacy; end

  def partner_terms; end

  def contact
    @contact_email = ENV["CONTACT_EMAIL"].presence
  end
end
