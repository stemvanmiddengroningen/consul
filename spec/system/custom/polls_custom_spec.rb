require "rails_helper"

describe "Polls custom" do
  scenario "Poll one shows custom video" do
    first_poll = create(:poll, id: 1)
    second_poll = create(:poll)
    third_poll = create(:poll)

    visit poll_path(first_poll)

    expect(page).to have_css "#polls_custom_video"
    expect(page.find(:css, "iframe")[:src]).to eq "https://www.youtube.com/embed/kM04Nt2ehq4"

    visit poll_path(second_poll)

    expect(page).not_to have_css "#polls_custom_video"
    expect(page).not_to have_css "iframe"

    visit poll_path(third_poll)

    expect(page).not_to have_css "#polls_custom_video"
    expect(page).not_to have_css "iframe"
  end
end
