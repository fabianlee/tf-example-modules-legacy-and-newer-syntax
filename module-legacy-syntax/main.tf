
# legacy syntax (< v0.10) of provider blocks directly inside module
provider null { }
provider time { }

# use of null provider
resource null_resource     test_rs  {}
resource null_resource     test_rs2 {}
data     null_data_source  test_ds  {}

# use of time provider
resource time_static example {}
#output myvar { value="module ${time_static.example.rfc3339}" }
