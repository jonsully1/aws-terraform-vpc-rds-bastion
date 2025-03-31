include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/key-pairs"
}

inputs = {
root_directory = get_terragrunt_dir()
}