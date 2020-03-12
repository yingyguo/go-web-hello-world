This is a demo project required by SRE role. 

The candidate should be able to complete the project independently in two days and well document the procedure in a practical and well understanding way.

It is not guaranteed that all tasks can be achieved as expected, in which circumstance, the candidate should trouble shoot the issue, conclude based on findings and document which/why/how.
____

### Task 0: Install a ubuntu 16.04 server 64-bit

*either in a physical machine or a virtual machine*

*http://releases.ubuntu.com/16.04/<br>*

*http://releases.ubuntu.com/16.04/ubuntu-16.04.6-server-amd64.iso<br>*

*https://www.virtualbox.org/*

*for VM, use NAT network and forward required ports to host machine*
*- 22->2222 for ssh*
*- 80->8080 for gitlab*
*- 8081/8082->8081/8082 for go app*
*- 31080/31081->31080/31081 for go app in k8s*

#### Device:

    virtualbox6.0
    
Create a new Ubuntu 16.04 on VirtualBox.

The configuration is as follows：

    * 4 CPUs (k8s requires at least 2 CPUs)
    * 8GB of Memory (at least 2 GB)
    * 80GB of Virtual Size 
    * Nat Mode
    
The setup step is omitted here...

Ubuntu get ip address is 10.0.2.15
Ubuntu create user is : ezguoyi

Configure the port forwarding required above...

### Task 1: Update system
*ssh to guest machine from host machine ($ ssh user@localhost -p 2222) and update the system to the latest*
*https://help.ubuntu.com/16.04/serverguide/apt.html*
*upgrade the kernel to the 16.04 latest*

#### Update all Packages
    #sudo apt update
    #sudo apt upgrade
    #sudo reboot
    #sudo apt list --upgradeable (check )

#### Update kernel version
    Go to https://kernel.ubuntu.com/~kernel-ppa/mainline/ find the latest kernel version(5.5.8)
    #uname -r (Check the currently used kernel version)
    If it's not the latest version, install the latest kernel version.
    Go to https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.5.8/
    #wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.5.8/linux-headers-5.5.8-050508-generic_5.5.8-050508.202003051633_amd64.deb
    #wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.5.8/linux-headers-5.5.8-050508_5.5.8-050508.202003051633_all.deb
    #wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.5.8/linux-image-unsigned-5.5.8-050508-generic_5.5.8-050508.202003051633_amd64.deb
    #wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.5.8/linux-modules-5.5.8-050508-generic_5.5.8-050508.202003051633_amd64.deb
    #sudo dpkg -i *.deb
    #sudo reboot
    #uname -r (Check whether the upgrade is successful)

#### TroubleShooting:

    If Guru Meditation error occurs in virtualbox after reboot, Please try to restart your computer.
    If ubuntu keeps hanging on " a start job is running for dev-mapper-cryptswap1.device ... ", try to restart Ubuntu through the VirtualBox interface,
    select recovery mode to access Ubuntu for repair.

### Task 2: install gitlab-ce version in the host

*https://about.gitlab.com/install/#ubuntu?version=ce*

*Expect output: Gitlab is up and running at http://127.0.0.1 (no tls or FQDN required)*

*Access it from host machine http://127.0.0.1:8080*

#### Steps are as follows：

    #sudo apt-get install -y curl openssh-server ca-certificates
    #sudo apt-get install -y postfix
    #curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
    #sudo EXTERNAL_URL="http://127.0.0.1" apt-get install gitlab-ce
    #sudo vim /opt/gitlab/embedded/service/gitlab-rails/config/gitlab.yml (Modify gitlab port to 8080.)
    #sudo gitlab-ctl restart
    
If you do not modify the gitlab port, the file in the repo will be linked to port 80 when you access the gitlab file from the host browser,
resulting in file access failure.

### Task 3: create a demo group/project in gitlab

*named demo/go-web-hello-world (demo is group name, go-web-hello-world is project name).*
*Use golang to build a hello world web app (listen to 8081 port) and check-in the code to mainline.*
*https://golang.org/<br>*
*https://gowebexamples.com/hello-world/*
*Expect source code at http://127.0.0.1:8080/demo/go-web-hello-world*

#### Install goalng1.12

    #wget https://studygolang.com/dl/golang/go1.12.linux-amd64.tar.gz
    #sudo tar -zxvf go1.12.linux-amd64.tar.gz -C /usr/lib
    #export GOROOT=/usr/lib/go
    #export PATH=$PATH:$GOROOT/bin
    #export GOARCH=amd64
    or Write these three variables to ~/.profile
    
#### Genrate sshkey

    #ssh-keygen -t rsa -C "yingying.guo@ericsson.com"
    #cat ~/.ssh/id_rsa.pub 
    Upload this content to gitlab

Create golang hello-world project(go-web-hello-world), Omit here....
Modify the listening port to 8081 in main.go...

### Task 4: build the app and expose ($ go run) the service to 8081 port

    #mkdir demo & cd demo
    #git clone git@127.0.0.1:demo/go-web-hello-world.git
    #cd go-web-hello-world
    #go run .
    
    You can visit http://127.0.0.1:8081 through the host browser.
    you will get "Hello, you've requested: /".
    
### Task 5: install docker    
*https://docs.docker.com/install/linux/docker-ce/ubuntu/*

#### Install Docker CE

    #sudo apt-get update
    #sudo apt-get install apt-transport-https ca-certificates curl  gnupg-agent  software-properties-common
    #curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    #sudo add-apt-repository  "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    #sudo apt-get update
    #sudo apt-get install docker-ce docker-ce-cli containerd.io
    #sudo docker run hello-world(check)
    #sudo usermod -aG docker ezguoyi(Add ezguoyi user to docker group)
    #newgrp docker (update group)
    
### Task 6: run the app in container

*build a docker image ($ docker build) for the web app and run that in a container ($ docker run), expose the service to 8082 (-p)*

*https://docs.docker.com/engine/reference/commandline/build/*

*Check in the Dockerfile into gitlab*

#### Docker add HTTP proxy(K8s images can be downloaded quickly)

    #sudo mkdir -p /etc/systemd/system/docker.service.d
    #sudo vim /etc/systemd/system/docker.service.d/http-proxy.conf
    #cat  /etc/systemd/system/docker.service.d/http-proxy.conf
        [Service]
        Environment="HTTP_PROXY=http://www-proxy.ericsson.se:8080" "HTTPS_PROXY=http://www-proxy.ericsson.se:8080" "NO_PROXY=localhost,127.0.0.1,docker-registry.somecorporation.com"
        
    #systemctl daemon-reload
    #systemctl restart docker
    
#### Create dockerfile

    #vim Dockerfile
    #cat Dockerfile
        FROM golang:1.12.7 as builder
        WORKDIR /go/src/app
        
        COPY main.go .
        RUN CGO_ENABLED=0 GOOS=linux go build -o go-web-hello-world .
        
        FROM scratch
        COPY --from=builder /go/src/app/go-web-hello-world /
        CMD ["/go-web-hello-world"]
        
    # docker build -t go-web-hello-world:v0.1 .
    # docker run -d -p 8083:8081 --name go-demo go-web-hello-world:v0.1
    
    (Since port 8082 is used by sidekiq, I use port 8083)
    You can visit http://127.0.0.1:8082 through the host browser.
    you will get "Hello, you've requested: /".
    
### Task 7: push image to dockerhub

*tag the docker image using your_dockerhub_id/go-web-hello-world:v0.1 and push it to docker hub (https://hub.docker.com/)*

*Expect output: https://hub.docker.com/repository/docker/your_dockerhub_id/go-web-hello-world*

    #docker login (my account: goguo)
    #docker tag go-web-hello-world:v0.1 goguo/go-web-hello-world:v0.1
    #docker push goguo/go-web-hello-world:v0.1
    
    You can access it via the following link：
    [https://hub.docker.com/repository/docker/goguo/go-web-hello-world](https://hub.docker.com/repository/docker/goguo/go-web-hello-world)
        
### Task 8: document the procedure in a MarkDown file
*create a README.md file in the gitlab repo and add the technical procedure above (0-7) in this file*

......

### Task 9: install a single node Kubernetes cluster using kubeadm

*https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/*

*Check in the admin.conf file into the gitlab repo*

##### Install kubeadm

    #sudo apt-get update && sudo apt-get install -y apt-transport-https curl
    #curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    #cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
        deb https://apt.kubernetes.io/ kubernetes-xenial main 
        EOF
        
    #sudo apt-get update
    #sudo apt-get install -y kubelet kubeadm kubectl
    #sudo apt-mark hold kubelet kubeadm kubectl
    
#### Modity docker cgroup driver

    (Because it is not the same as the default driver of kubelet, I choose to modify docker)

    #cat /etc/docker/daemon.json 
        {
        "exec-opts":["native.cgroupdriver=cgroupfs"]
        }
        
    #systemctl daemon-reload
    #systemctl restart docker

#### Kubeadm init(install the default version)

    #kubeadm init --apiserver-advertise-address=10.0.2.15 --pod-network-cidr=192.168.0.0/16
    
#### Install calico

    #wget  https://docs.projectcalico.org/v3.8/manifests/calico.yaml
    #kubectl apply -f calico.yaml
    #kubectl get node(check)

#### Access k8s

    #mkdir -p $HOME/.kube
    #sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    #sudo chown $(id -u):$(id -g) $HOME/.kube/config
    #kubectl get node
        NAME              STATUS   ROLES    AGE   VERSION
        ubuntu-guo-test   Ready    master   29h   v1.17.3

#### Configure master to deploy pod

    #kubectl taint nodes --all node-role.kubernetes.io/master-

### Task 10: deploy the hello world container

*in the kubernetes above and expose the service to nodePort 31080*

#### Deploy demo 

    #vim deployment.yaml (Please refer to the code file deployment.yaml)
    #kubectl create ns demo
    #kubectl create -f deployment.yaml
    #kubectl get pod -n demo
    NAME                       READY   STATUS    RESTARTS   AGE
    go-demo-754fdfbd55-cdwvj   1/1     Running   0          21h
    
#### Troubleshooting:

    If pod is in the pending state
    #kubectl describe pod go-demo-754fdfbd55-cdwvj -n demo
    if it shows "0/1 nodes are available: 1 node(s) had taints that the pod didn't tolerate"
    #kubectl describe node  ubuntu-guo-test
    if there are disk related values in Taints, and error shows "failed to garbage collect required amount of images. Wanted to free..."
        Please check if you have enough disk space.
        To increase the Ubuntu disk space, please refer to：
        [https://blog.csdn.net/ouyang_peng/article/details/53261599](https://blog.csdn.net/ouyang_peng/article/details/53261599)
        [https://blog.csdn.net/xatuo007/article/details/100733796](https://blog.csdn.net/xatuo007/article/details/100733796)
    
### Task 11: install kubernetes dashboard and expose the service to nodeport 31081

*https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/*
*Expect output: https://127.0.0.1:31081 (asking for token)*

    #kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml
    #kubectl proxy --address=0.0.0.0  --port=31081 &
    
### Task 12: generate token for dashboard login in task 11
*figure out how to generate token to login to the dashboard and publish the procedure to the gitlab.*

#### Generate token to login the dashboard

    #kubectl create serviceaccount cluster-dashboard-demo
    #kubectl create clusterrolebinding cluster-dashboard-demo --clusterrole=cluster-admin --serviceaccount=default:cluster-dashboard-demo
    #kubectl get secret
    #kubectl get secret cluster-dashboard-demo-token-mwspb
    #kubectl describe secret cluster-dashboard-demo-token-mwspb 
    Copy the token field to the login page
    
    
#### Dashboard

![k8s dashboard](https://github.com/yingyguo/go-web-hello-world/blob/master/dashboard.PNG)

    


    


    
    
    
    
    


    

    
    

    

    







