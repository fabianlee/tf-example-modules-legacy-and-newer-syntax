
terraform {
  required_providers {
    null = { 
      source = "hashicorp/null"
      version = ">= 3.2.0"
    }
  }
}

# terraform destroy --target module.mymodule_legacysyntax
#module mymodule_legacysyntax {
#  source = "./module-legacy-syntax"
#}

# terraform destroy --target module.mymodule_newersyntax
module mymodule_newersyntax {
  source = "./module-newer-syntax"
}

output myvar { value="main" }
