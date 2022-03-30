# deploy-lambda-containers-with-terraform

## Usage

### To update MakeFile
Run command
```shell
make
```

### Check if Terraform is installed
Run command
```shell
make local
```

### To setup and preview resources with Terraform
Run command
```shell
make plan
```

### To build resource or update with Terraform
Run command
```shell
make apply
```

### To delete all resource with Terraform
Run command
```shell
make destroy
```

### To delete Terraform generated files in local directory
Run command
```shell
make clean
```

### After the user clones a copy of the public code
> This command copies and compresses the required code to a location the **git-private** has access. 
Run command
```shell
make git-public
```

### Setup the private CodeCommit respository with a first commit 
Run command
```shell
make git-private
```

### Uploads the code to invoke a build in the CodePipeline 
> This command extracts the required code into the CodeCommit **private** respository. 
Run command
```shell
make upload
```