# docker-github

This is an example Docker project that shows how to pull content from GitHub during the Docker build process. It uses a GitHub deploy key to do this.

The GitHub repo being cloned into the Docker image at build time is https://github.com/CU-CloudCollab/docker-github-target. That repo has been configured with [keys/example_deploy_rsa.pub](keys/example_deploy_rsa.pub) as a read-only deploy key in GitHub. Normally we wouldn't store either the public or private part of the deploy keys in a repo. We do that here in order to provide a functioning example. See [keys/README.md](keys/README.md) for more info.

See [GitHub Credentials Management](https://confluence.cornell.edu/display/CLOUD/GitHub+Credentials+Management) for how this fits into a larger git credentials management scheme.

## Caution!

Be aware that the contents of the `/keys` directory is present in intermediate layers of the Docker image. This means that a bad guy could root out the contents of the `/keys` directory if he had access to the Docker image.

## Run the example

The main point here is to show how a [Dockerfile](Dockerfile) can be used to clone a private GitHub repo that has a deploy key configured for it.

To run the example:

1. Clone this repo onto your workstation and cd into the repo directory.

  ```
  $ git clone https://github.com/CU-CloudCollab/docker-github.git
  Cloning into 'docker-github'...
  remote: Counting objects: 15, done.
  remote: Compressing objects: 100% (13/13), done.
  remote: Total 15 (delta 0), reused 15 (delta 0), pack-reused 0
  Unpacking objects: 100% (15/15), done.
  $ cd docker-github
  $
  ```

2. Run the Docker build process via the included custom script.

  ```
  $ ./go-build.sh
  Sending build context to Docker daemon 86.02 kB
  Step 1/10 : FROM ubuntu:16.04
  16.04: Pulling from library/ubuntu
  8aec416115fd: Pull complete
  695f074e24e3: Pull complete
  946d6c48c2a7: Pull complete
  bc7277e579f0: Pull complete
  2508cbcde94b: Pull complete
  Digest: sha256:71cd81252a3563a03ad8daee81047b62ab5d892ebbfbf71cf53415f29c130950
  Status: Downloaded newer image for ubuntu:16.04
   ---> f49eec89601e
  Step 2/10 : MAINTAINER Cornell IT Cloud DevOps Team <cloud-devops@cornell.edu>
   ---> Running in a5ce9fa50f3c
   ---> 99990a401264
  Removing intermediate container a5ce9fa50f3c
  Step 3/10 : ENV DEPLOY_KEY_PRIVATE example_deploy_rsa
   ---> Running in 2587ee06cbc6
   ---> 0838618e7b90
  Removing intermediate container 2587ee06cbc6
  Step 4/10 : RUN apt-get update &&   apt-get install -y ssh git-core &&   rm -rf /var/lib/apt/lists/*
   ---> Running in f2532c920290
  Get:1 http://archive.ubuntu.com/ubuntu xenial InRelease [247 kB]
  Get:2 http://archive.ubuntu.com/ubuntu xenial-updates InRelease [102 kB]
  Get:3 http://archive.ubuntu.com/ubuntu xenial-security InRelease [102 kB]
  Get:4 http://archive.ubuntu.com/ubuntu xenial/main Sources [1103 kB]
  [------------LOTS OF OUTPUT CLIPPED------------]
   ---> 0da09052efee
  Removing intermediate container f2532c920290
  Step 5/10 : COPY keys/ /keys
   ---> d68e266b9e3c
  Removing intermediate container f117d148d0b7
  Step 6/10 : ADD version /tmp/version
   ---> 424abbc9a7a3
  Removing intermediate container 510dbc9991b5
  Step 7/10 : RUN mkdir -p /root/.ssh/ &&   cp /keys/$DEPLOY_KEY_PRIVATE /root/.ssh/id_rsa &&   chmod 400 /root/.ssh/id_rsa &&   touch /root/.ssh/known_hosts &&   ssh-keyscan github.com >> /root/.ssh/known_hosts
   ---> Running in 3b40bbb6e32e
  # github.com:22 SSH-2.0-libssh-0.7.0
  # github.com:22 SSH-2.0-libssh-0.7.0
  # github.com:22 SSH-2.0-libssh-0.7.0
   ---> 3a1ba7397295
  Removing intermediate container 3b40bbb6e32e
  Step 8/10 : WORKDIR /tmp
   ---> 75b4531a6a30
  Removing intermediate container e8b544ee1847
  Step 9/10 : RUN git clone git@github.com:CU-CloudCollab/docker-github-target.git
   ---> Running in d523464011e5
  Cloning into 'docker-github-target'...
  Warning: Permanently added the RSA host key for IP address '192.30.253.112' to the list of known hosts.
   ---> 6b914121720b
  Removing intermediate container d523464011e5
  Step 10/10 : RUN rm -rf /root/.ssh &&   rm -rf /keys
   ---> Running in eb2226e0a88f
   ---> 764b10afbaec
  Removing intermediate container eb2226e0a88f
  Successfully built 764b10afbaec
  $
  ```

3. Confirm that the target repo has been cloned into the image by running a container based on the image. The image built is tagged as `example` by the `go-build.sh` script.

  ```
  $ docker run -it example bash
  root@754957c06ec3:/tmp# ls -al docker-github-target
  total 16
  drwxr-xr-x 3 root root 4096 Feb  7 18:37 .
  drwxrwxrwt 1 root root 4096 Feb  7 18:37 ..
  drwxr-xr-x 8 root root 4096 Feb  7 18:37 .git
  -rw-r--r-- 1 root root   38 Feb  7 18:37 README.md
  root@754957c06ec3:/tmp# exit
  exit
  $
  ```

