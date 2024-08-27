require "rails_helper"

describe "Installation details" do
  scenario "Show the current version of CONSUL" do
    visit root_path
    within(".footer") do
      expect(page).not_to have_content "2.1.1"
      expect(page).not_to have_content Time.current.year.to_s
    end
  end
end
