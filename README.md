# ubuntu_dev

### get code:
    git clone https://github.com/hanger0106/ubuntu_dev.git
    
### build docker image from git:
    docker build --tag ubuntu_dev https://github.com/hanger0106/ubuntu_dev.git#main:.    

### build docker image from local:
    docker build --tag ubuntu_dev .
    
### docker run command:
    docker run -it --rm  -e USER_ID=${UID} ubuntu_dev bash
Or, add current dir to docker:
( '.bashrc' file will be called if you do have it in $PWD:/work )

    docker run -it --rm  -v ${PWD}:/work -e USER_ID=${UID} ubuntu_dev bash

Or, when no need --rm option, simple remove it, remember to kill it by your own
    
    docker run -it -v ${PWD}:/work -e USER_ID=${UID} ubuntu_dev bash
    
### Push code:
    git push

### Switch to Ubuntu 16.04 branch:
$ git branch -a
* main
  remotes/origin/16.04
  remotes/origin/16.04_386
  remotes/origin/18.04
  remotes/origin/20.04
  remotes/origin/HEAD -> origin/main
  remotes/origin/main

$ git checkout --track origin/16.04
