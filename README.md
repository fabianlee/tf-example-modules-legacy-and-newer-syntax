# Fixing 'Provider configuration not present' in modules using legacy provider blocks

blog: https://fabianlee.org/2023/08/27/terraform-error-removing-module-containing-legacy-provider-block-provider-configuration-not-present/

If you are dealing with legacy Terraform syntax where provider blocks are written directly inside the modules, then you will run into issues if you simply remove the 'module' declaration from the main tf configuration.

The proper order is to first remove the module from state, and only then remove its module declaration from your main.tf

```
# syntax
#terraform destroy --target module.<moduleName>:

# example
terraform destroy --auto-approve --target module.mymodule_legacysyntax

# now apply should work again
terraform apply
```

If you removed the module declaration from main.tf first, you will get an error similar to below:

```
Error: Provider configuration not present

To work with module.mymodule_legacysyntax.null_resource.test_rs (orphan) its original provider configuration at
module.mymodule_legacysyntax.provider["registry.terraform.io/hashicorp/null"] is required, but it has been removed.
This occurs when a provider configuration is removed while objects created by that provider still exist in the state.
Re-add the provider configuration to destroy module.mymodule_legacysyntax.null_resource.test_rs (orphan), after which
you can remove the provider configuration again.
```

In this case, you need to add the module declaration back to your main configuration and run the following commands

```
terraform init --upgrade
terraform destroy --auto-approve --target module.<moduleName>

# should now be ok
terraform apply
```


## Scenario 2: Removing single legacy provider block inside module

If you are attempting to remove a single legacy provider block inside a module and get this error, then you need to reinclude the provider and its resources, then manually remove each resource state.

```
# if state is remote, download
[[ -f terraform.tfstate ]] || terraform state pull > terraform.tfstate

my_module="module.mymodule_legacysyntax"
my_module_source="hashicorp/null"

#
# use whichever parser you prefer (jq or yq) to identify resources to remove
#
# jq commands to print resource destruction commands for provider within module
jq -r ".resources[] | select(.module == \"$my_module\" and .mode == \"managed\" and (.provider | contains(\"$my_module_source\")) ) | [.module,.type,.name] | @csv" terraform.tfstate | sed 's/\"//g; s/,/\./g' | xargs printf "terraform destroy --auto-approve --target %s\n"

# yq commands to print resource destruction commands for provider within module
yq e ".resources[] | select(.module == \"$my_module\" and .mode == \"managed\" and (.provider | contains(\"$my_module_source\")) ) | [.module,.type,.name]" terraform.tfstate -o=csv | sed 's/,/\./g' | xargs printf "terraform destroy --auto-approve --target %s\n"

# rerun init
terraform init --upgrade

# now apply should work again
terraform apply
```
