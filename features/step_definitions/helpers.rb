require 'capybara/cucumber'
Capybara.app = DaKroken

When /I loggin/ do
    fill_in 'user', :with => 'Magnus'
    fill_in 'pass', :with => '477951Aa'
    click_button 'Logga in'
end