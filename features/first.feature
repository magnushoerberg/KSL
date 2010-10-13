Feature: First Page
	Scenario: Title on the home page
		Given I am on the home page
		Then I should see "DA schema"
	
	Scenario: There should be a callender to choose different dates from
		Given I am on the home page
		When I fill in "datepicker" with "2010-10-07"
		And I press "Schema"
		Then I should see "2010-10-07"
		When I fill in "fridge" with "Magnus"
		And I fill in "carry" with "Magnus"
		And I fill in "bar" with "Magnus"
		And I fill in "chef" with "Magnus"
		And I press "spara"
		Then I should be on the home page
		And I should see "Kröken 2010-10-07"
		And I should see "Fylla kylen gör Magnus"
		And I should see "Bära barer gör Magnus"
		And I should see "Jobbar i baren gör Magnus"
		And I should see "Basar i köket gör Magnus"
	
	Scenario: Remove a submited work pass
		Given I am on the home page
		When I fill in "datepicker" with "2010-10-07"
		And I press "Schema"
		Then I should see "2010-10-07"
		When I fill in "fridge" with "Magnus"
		And I press "spara"
		Then I should be on the home page
		And I should see "Fylla kylen gör Magnus" within "2010-10-07T00:00:00+00:00"
		When I press "Kan inte fylla kylen"
		Then I should be on the home page
		And I should not see "Fylla kylen gör Magnus" within "2010-10-07T00:00:00+00:00"