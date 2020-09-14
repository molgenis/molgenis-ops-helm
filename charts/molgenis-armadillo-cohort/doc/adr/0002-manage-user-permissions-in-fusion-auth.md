# 2. Manage user permissions in Fusion Auth

Date: 2020-09-14

## Status

Proposed

## Context
In Armadillo:

* A cohort is an OpenID application
* The researcher needs a `ROLE_<STUDY>_RESEARCHER` to read data in shared folder `<study>`

Requirements on who manages what:

* User and permission management is done by representatives of the consortium and cohort
* The identity of the user is federated to their local institution
* Representatives of the consortium administer the user’s membership of a study
* Representatives of the cohort administer the study researchers’ admission to their cohort

## Decision

Implement this in Fusion Auth, plus a (modest) administration UI.

* A study is a group
* The users register themselves, the consortium creates study groups and makes users a member of the study group
* The cohort representative explicitly creates a registration for the researcher in the application
(or enables auto registration)
* The cohort gives the study groups a role on the application

### Administration

Application-specific permissions are not available in Fusion Auth. In other products they tend to be rather complicated to configure.

Create an edge service that enforces the permissions and uses an api key to administer them through the Fusion Auth API.

## Consequences

* Need to build the service and a UI
* Clear specific UIs for the cohort manager and consortium manager