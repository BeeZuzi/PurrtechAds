module ContractRequestsHelper
  def country_options
    ISO3166::Country.all.map { |c| [c.common_name || c.iso_short_name, c.alpha2] }.compact.sort_by(&:first)
  end
end
