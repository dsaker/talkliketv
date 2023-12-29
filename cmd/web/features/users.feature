Feature: User Sign Up
  User should be able to signup with correct payload

  Scenario: Sign Up Success
    Given the payload:
        """
        {
            "name": "newUser",
            "email": "newUser@example.com",
            "password": "pa55word",
            "language": "Spanish"
        }
        """
    When I send a "POST" request to "/user/signup"
    Then the response code should be "200"
