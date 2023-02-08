---
title: 本地部署minikube
date: 2023-02-08 15:29:55
tags:
    - Linux
    - Docker
categories:
    - Docker
---

Minikube is local Kubernetes, focusing on making it easy to learn and develop for Kubernetes.

官网：https://minikube.sigs.k8s.io/docs/start/

Kubernetes: https://kubernetes.io/
<!-- more -->
# 2. 部署

## 2.1 环境要求
- CPU: 4+
- Memory: 16G+
- OS: Linux
- Kernel: 3.10.107-1-tlinux2_kvm_guest-0054

更新内核：

```shell
yum -y update kernel
reboot
```

## 2.2 创建普通用户并加入docker用户组

- 创建用户

```shell
# 增加用户nutao
useradd nutao
# 设置密码
passwd nutao
```

- 更新root用户组，使nutao拥有sudo权限

```shell
visudo
```

在root用户权限后添加nutao用户的权限

```
## Allow root to run any commands anywhere
root    ALL=(ALL)       ALL
nutao   ALL=(ALL)       ALL
```

- 将nutao用户加入到docker用户组

```shell
# root切换用户
su - nutao
# nutao 加入到docker组
sudo usermode -aG docker nutao
# 登录到用户组docker
newgrp docker
```

## 2.3 安装minikube

```shell
# 下载minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# 安装minikube
sudo minikube start

# 验证安装
minikube kubectl -- get po -A

# 更新kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

# 3. 部署应用

支持的插件（应用包）：

```
minikube addons list

|-----------------------------|----------|--------------|-----------------------|
|         ADDON NAME          | PROFILE  |    STATUS    |      MAINTAINER       |
|-----------------------------|----------|--------------|-----------------------|
| ambassador                  | minikube | disabled     | unknown (third-party) |
| auto-pause                  | minikube | disabled     | google                |
| csi-hostpath-driver         | minikube | disabled     | kubernetes            |
| dashboard                   | minikube | enabled ✅   | kubernetes            |
| default-storageclass        | minikube | enabled ✅   | kubernetes            |
| efk                         | minikube | disabled     | unknown (third-party) |
| freshpod                    | minikube | disabled     | google                |
| gcp-auth                    | minikube | disabled     | google                |
| gvisor                      | minikube | disabled     | google                |
| helm-tiller                 | minikube | disabled     | unknown (third-party) |
| ingress                     | minikube | disabled     | unknown (third-party) |
| ingress-dns                 | minikube | disabled     | unknown (third-party) |
| istio                       | minikube | disabled     | unknown (third-party) |
| istio-provisioner           | minikube | disabled     | unknown (third-party) |
| kubevirt                    | minikube | disabled     | unknown (third-party) |
| logviewer                   | minikube | disabled     | google                |
| metallb                     | minikube | disabled     | unknown (third-party) |
| metrics-server              | minikube | disabled     | kubernetes            |
| nvidia-driver-installer     | minikube | disabled     | google                |
| nvidia-gpu-device-plugin    | minikube | disabled     | unknown (third-party) |
| olm                         | minikube | disabled     | unknown (third-party) |
| pod-security-policy         | minikube | disabled     | unknown (third-party) |
| registry                    | minikube | disabled     | google                |
| registry-aliases            | minikube | disabled     | unknown (third-party) |
| registry-creds              | minikube | disabled     | unknown (third-party) |
| storage-provisioner         | minikube | enabled ✅   | kubernetes            |
| storage-provisioner-gluster | minikube | disabled     | unknown (third-party) |
| volumesnapshots             | minikube | disabled     | kubernetes            |
|-----------------------------|----------|--------------|-----------------------|
```

## 3.1 dashboard

未配置ingress时，需要借助**vscode**进行端口转发以支持远程访问。

```shell
[nutao@VM-244-79-centos ~]$ minikube dashboard
🤔  Verifying dashboard health ...
🚀  Launching proxy ...
🤔  Verifying proxy health ...
🎉  Opening http://127.0.0.1:40539/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/ in your default browser...
👉  http://127.0.0.1:40539/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
```

![image-20210827173252273](./%E6%9C%AC%E5%9C%B0%E9%83%A8%E7%BD%B2minikube/1.png)



## 3.2 启用ingress-nginx

```shell
minikube addons enable ingress

    ▪ Using image k8s.gcr.io/ingress-nginx/controller:v0.44.0
    ▪ Using image docker.io/jettech/kube-webhook-certgen:v1.5.1
    ▪ Using image docker.io/jettech/kube-webhook-certgen:v1.5.1
🔎  Verifying ingress addon...
🌟  The 'ingress' addon is enabled
```

外部访问ingress

```shell
# 将服务器本机的8080端口转发到ingress服务的80端口，实现外部访问
kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8080:80 --address 0.0.0.0
```



## 3.3 部署nginx-demo应用

- namespace 命名空间
  - 资源隔离，权限控制
- deployment 部署负载
  - 声明资源（容器）部署
  - k8s deployController会根据yaml创建出指定个数的pod
- service：服务
  - 将deployment中声明创建出的pod包装成一个网络服务。
  - 在同一命名空间中，可以直接访问服务来访问到其代理的后端Pod负载
- ingress：
  - 对集群中服务的外部访问进行管理的 API 对象
  - ingressController会为ingress对象分配一个可以直接访问的网桥IP
  - [Ingress](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#ingress-v1beta1-networking-k8s-io) 公开了从集群外部到集群内[服务](https://kubernetes.io/zh/docs/concepts/services-networking/service/)的 HTTP 和 HTTPS 路由。 流量路由由 Ingress 资源上定义的规则控制。

![image-20210831112505474](./%E6%9C%AC%E5%9C%B0%E9%83%A8%E7%BD%B2minikube/2.png)

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: nutao-demo
spec:
  finalizers:
  - kubernetes
 
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-deploy
  namespace: nutao-demo
spec:
  selector:
    matchLabels:
      app: demo
  replicas: 2
  template:
    metadata:
      labels:
        app: demo
    spec:
      containers:
        - name: demo
          image: nginx:latest
          ports:
            - containerPort: 80
          resources:
            requests:
              cpu: "10m"
              memory: "20Mi"
            limits:
              cpu: "100m"
              memory: "100Mi"

---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: nutao-demo
spec:
  selector:
    app: demo
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  namespace: nutao-demo
spec:
  rules:
    - http:
        paths:
          - pathType: Prefix
            path: "/"
            backend:
              service:
                name: nginx-service
                port:
                  number: 80
```



# 4. 其他

创建镜像仓库secret凭证

```yaml
kubectl create secret docker-registry tsf-registry-secret  --docker-password="xxxx"  --docker-username="xxxx"  --docker-server="https://ccr.ccs.tencentyun.com" -n nutao-demo
```



