
# newer syntax for providers
terraform {
  required_providers {
    null = { 
      source = "hashicorp/null"
      version = "3.2.1"
    }
    time = { source = "hashicorp/time" }
  }
}

# usage of null provider
resource null_resource     test_rs {}
data     null_data_source  test_ds {}

# usage of time provider
resource time_static example {}
