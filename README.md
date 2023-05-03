# ubuntu_dev

### get code:
    git clone https://github.com/hanger0106/ubuntu_dev.git
    
### build docker image from git:
    docker build --tag ubuntu_dev https://github.com/hanger0106/ubuntu_dev.git#20.04:.    

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
    git checkout -b 16.04 origin/16.04
### Switch to Ubuntu 20.04 branch:
    git checkout -b 20.04 origin/20.04
