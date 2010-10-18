Feature: First Page
	Scenario: Title on the home page
		Given I am on the home page
		When I loggin
		Then I should see "DA"
		
	Scenario: There should be a callender to choose different dates from
		Given I am on the home page
		When I loggin
		And I fill in "datepicker" with "2010-10-27"
		And I press "Schema"
		When I fill in "fridge" with "Magnus"
		And I fill in "carry" with "Magnus"
		And I fill in "bar" with "Magnus"
		And I fill in "chef" with "Magnus"
		And I press "spara"
		Then I should be on the home page
		And I should see "Kröken 2010-10-27"
		And I should see "Fylla kylen gör Magnus"
		And I should see "Bära barer gör Magnus"
		And I should see "Står i baren gör Magnus"
		And I should see "Står i köket gör Magnus"
		
	Scenario: Remove a submited work pass
		Given I am on the home page
		When I loggin
		And I fill in "datepicker" with "2010-10-27"
		And I press "Schema"
		And I fill in "fridge" with "Magnus"
		And I press "spara"
		Then I should be on the home page
		And I should see "Fylla kylen gör Magnus"
		When I follow "Din personliga sida"
		And I press "Magnus kan inte fylla kylarna"
		And I follow "Standardsidan"
		Then I should be on the home page
		And I should not see "Fylla kylen gör Magnus"
	
	Scenario: Place an order for beer
		Given I am on the home page
		When I loggin
		And I fill in "datepicker" with "2010-10-21"
		And I press "Schema"
		And I follow "Hämta ut alkohol"
		And I fill in "article" with "Spendrups export"
		Then I should see "Spendrups export"
		And I should see "12.8kr exkl. moms"
		When I fill in "amount" with "40"
		And I press "Hämta ut"
		Then I should see "Kröken 2010-10-21"
		And I should see "Spendrups export 40st"