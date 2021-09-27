# Airflow
A pipeline configuration tool.

## Usage

### General settings
When you deploy Airflow in Kubernetes you need to set a couple of general settings.
- Airflow host --> is the domain where airflow is hosted on
- Flower host --> should be the same as airflow host
- webserver base url --> should be the same as airflow host but with the scheme in front of it
- Fernet application key --> Airflow uses Fernet to encrypt passwords in the connection configuration and the variable configuration
- Fernet webserver key --> Same reason as the application key
### Authentication
To setup OIDC you have 2 components
- An OIDC provider
- An Airflow instance

**OIDC provider configuration**

*Add lambda to populate username in ID-token*
  - Navigate to "Customizations"
    - Navigate to "lambdas"
      - Add new lambda
      - Name it "populate username in id-token"
      - Choose type "JWT populate" 
      - Paste in the following code block
        ```javascript
        // Using the user and registration parameters add additional values to the jwt object.
        function populate(jwt, user, registration) {
        jwt.username = user.firstName + " " + user.lastName;
        }
        ```
        > IMPORTANT: be sure the attributes `user.firstName` and `user.lastName` exists and are populated. This is ID-provider dependant and not necessarily the way it is described above.
      - Save the lambda


*Add new application*
  - Navigate to auth.molgenis.org
    - Add new application
  - Name it according to the airflow app (e.g. [PROD] Airflow)
  - Add necessary roles (by clicking "Add role")
    - Make sure you add 'ADMIN' as superrole
  - Navigate to OAuth tab
    - Add the redirect url: https://#airflow-app#/oauth-/#oidc-name-in-airflow#
  - Navigate to JWT tab
    - Configure the ID-token lambda --> choose "populate username in id-token"
  - Save the application

*Configure roles on user*
  - Navigate to "Users"
  - Search your own user
  - Click on "Manage" (icon on the right)
  - Click on "Add registration"
  - Select the correct application (e.g. "[PROD] Airflow")
  - Select the role you want to have in the Airflow app

*Configure federative ID-providers for the application*
  - Navigate to "Settings"
  - Navigate to "Identitiy providers"
  - Click on "umcg"
  - Scroll all the way down
  - "Enable" the Airflow application and check "Create registration"

**Configure Ariflow**

*Deploy Airflow*
  - Click on the airflow catalog in Rancher
  - Specify the CLIENT_ID (can be found in the OAuth tab in the application view in https://auth.molgenis.org)
  - Specify the CLIENT_SECRET (can be found in the OAuth tab in the application view in https://auth.molgenis.org)
  - Specify the authentication server domain
  - Specify the role mapping of the custom Airflow roles and or FusionAuth roles.

*Configure roles*
  - After login navigate to "Security" --> "List Roles"
  - Click on the "plus"-sign
  - Name the role (e.g. "Data", make sure the rolenames are camelcased)
  - Assign permissions to the role
  - Make sure the roles is configured in the https://auth.molgenis.org as well (all capitals)
  - Make sure the roles are mapped in the Airflow deployment configuration
    Check the values under `AUTH_ROLE_MAPPINGS` in the `values.yml`
    
### Dag configuration
To configure new jobs in Airflow we use a seperate repository: https://github.com/molgenis/molgenis-tools-airflow. In this repository we manage the jobs that we have in Airflow. 

At this stage we have a dag for each job.

Check: https://github.com/molgenis/molgenis-tools-airflow.

## Development
## Install it locally
You can install AirFlow locally using [minikube](https://minikube.sigs.k8s.io/docs/start/) and [helm](https://helm.sh)

helm install . -n airflow --generate-name --create-namespace
## Portforward locally
sudo kubectl port-forward pod/chart-#hash#-web-#hash# 80:8080  