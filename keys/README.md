# Warning

Normally we would not add anything in the `keys` directory to our git repo. But, the ssh key files in this directory are real and provided to create a working example anyone can run.

* [example_deploy_rsa](example_deploy_rsa) is the private ssh deploy key
* [example_deploy_rsa.pub](example_deploy_rsa.pub) is the public ssh key and is configured to be the read-only deploy key for https://github.com/CU-CloudCollab/docker-github-target.

Normally you would exclude the `keys` directory from the repo by including it in the  [.gitignore](../.gitignore) file for the repo. You would manage the public and private keys separately from any GitHub repo.