# ubuntu_dev

### get code:
    git clone https://github.com/hanger0106/ubuntu_dev.git
    git checkout -b 16.04 origin/16.04
    
### build docker image from git:
    docker build --tag ubuntu_dev:16 https://github.com/hanger0106/ubuntu_dev.git#16.04:.

### build docker image from local:
    docker build --tag ubuntu_dev:16 .
    
### docker run command:
    docker run -it --rm  -e USER_ID=${UID} ubuntu_dev:16 bash
    
Or, add current dir to docker:
( '.bashrc' file will be called if you do have it in $PWD:/work )

    docker run -it --rm  -v ${PWD}:/work -e USER_ID=${UID} ubuntu_dev:16 bash

Or, when no need --rm option, simple remove it, remember to kill it by your own
    
    docker run -it -v ${PWD}:/work -e USER_ID=${UID} ubuntu_dev:16 bash
