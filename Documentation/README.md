### timecard-app: ideas and plans

At the Detroit 2019 Sprint, a group considered the problem of tracking work toward a grant.  [TODO: finish high level business problem]

## Architecture
In Salesforce:

* An Opportunity (most likely representing a grant, perhaps as part of NPSP) exists

* Three custom objects implement the data structure

* A user-facing application provides the mechanism for staff members to enter work toward a grant


## Objects

* A custom object, __Staff\_\_c__, has a parent Contact and a parent Opportunity, and represents a person who does work toward a grant.
    * Holds payment rate information, separately for wage and benefits, for ease of typical reporting
    * Holds start and end dates for the staff member's eligibility to work toward the grant

* A custom object, __What\_\_c__, represents a type of work that can be done toward a grant.

* A custom object, __Timecard\_\_c__, has a parent Staff\_\_c and a parent What\_\_c, and represents an entry of work toward a grant.




