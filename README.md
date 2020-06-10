# osipi
Automated deployment of OSI PI using Terraform [GCP]

Execution Steps:
1. Export the service account key path to  GOOGLE_APPLICATION_CREDENTIALS environment variable:
    ```
    export GOOGLE_APPLICATION_CREDENTIALS=~/path-to-sa.json

    gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
    ```
2. Select the deployment model to execute under ~/osipi/deployment, there are three deployment model to select:
    1. Solor Server- Provisions resources required for OSI PI Server
    2. Solo Integrator- Provisions resources required for OSI PI Integrator
    3. Collective Deployment- Provisions OSI PI Server, and Integrator both

3. Configure the below values in `terraform.tfvars` file for a given deployment:
    1. `project_id` - Project ID for the deployment
    2. `region` - Region for the deployment
    3. `zone` - Zone for the deployment
    4. `network` - default value `null` will provision a new resource, to use an existing network, provide the network name
    5. `subnet` - default value `null` will provision a new resource, to use an existing subnet, provide the subnet name

4. Based on the selection, change the directory and execute below commands:
    1. `terraform init` - Initialize Terraform
    2. `terraform plan` - Review the Terraform plan output
    3. `terraform apply`- Apply the reviewed plan to create resources

ToDo:
1. Include CMEK encryptions
2. Include OSI PI Installation
3. Include configuration files
4. Include configuring ini files
5. Include Firewalls
6. Include HA setup
7. Include Active Directory & Domain Controller creation
8. Include integration between components
9. Include Automated bash script to switch between deployments