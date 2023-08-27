* Deleting Terraform modules with direct provider blocks (legacy)

If you are dealing with legacy Terraform syntax where provider blocks are written directly inside the modules, then you will run into issues if you simply remove the 'module' declaration from the main tf configuration.

You will first need to "terraform destroy" the module, and only then remove its module declaration from your main.tf

```
terraform destroy --target module.<moduleName>

terraform destroy --auto-approve --target module.mymodule_legacysyntax
```

If you removed the module declaration first, you will get an error similar to below

```
Error: Provider configuration not present
 
 To work with module.mymodule.null_resource.test (orphan) its original provider configuration at
 module.mymodule.provider["registry.terraform.io/hashicorp/null"] is required, but it has been removed. This occurs
 when a provider configuration is removed while objects created by that provider still exist in the state. Re-add the
 provider configuration to destroy module.mymodule.null_resource.test (orphan), after which you can remove the
 provider configuration again.
```

In this case, you need to add the module declaration back to your main configuration and run the following commands

```
terraform init --upgrade
terraform destroy --target module.<moduleName>.<providerName>

my_module="module.mymodule_legacysyntax"
my_module_source="hashicorp/null"
yq ".resources[] | select(.module == \"$my_module\" and .mode == \"managed\" and (.provider | contains(\"$my_module_source\")) ) | [.module,.type,.name]" -o=csv terraform.tfstate

# commands to destroy resources associated with module
yq e ".resources[] | select(.module == \"$my_module\" and .mode == \"managed\" and (.provider | contains(\"$my_module_source\")) ) | [.module,.type,.name]" terraform.tfstate -o=csv | sed 's/,/\./g' | xargs printf "terraform destroy --auto-approve --target %s\n"
```

And only then remove the module declaration from your main.tf




REFERENCES

https://developer.hashicorp.com/terraform/language/modules/develop/providers#legacy-shared-modules-with-provider-configurations

https://developer.hashicorp.com/terraform/tutorials/configuration-language/provider-versioning?utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS#explore-terraform-lock-hcl

https://registry.terraform.io/providers/hashicorp/null/latest/docs
https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/static

https://github.com/hashicorp/terraform/issues/22907


terraform destroy --target module.mymodule.null_resource.module_test
