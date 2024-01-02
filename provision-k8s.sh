#!/bin/bash

while ! [[ -f "/tmp/k8s/kube-token.sh" ]]; do
  sleep 5
done

## Instalação dos módulos do Kernel
echo "[TASK 1] Enable containerd modules: overlay and br_netfilter"
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Update hosts file
echo "[TASK 2] Update /etc/hosts file"
cat >>/etc/hosts<<EOF
192.168.56.10 controlplane.pauloxmachado.cloud controlplane
192.168.56.20 worker01.pauloxmachado.cloud worker01
192.168.56.30 worker02.pauloxmachado.cloud worker02
192.168.56.40 worker03.pauloxmachado.cloud worker03
192.168.56.50 jenkins.pauloxmachado.cloud jenkins
192.168.56.60 sonarqube.pauloxmachado.cloud sonarqube
192.168.56.70 gitlab.pauloxmachado.cloud gitlab
192.168.56.80 nexus.pauloxmachado.cloud nexus
192.168.56.200 nfs-server.pauloxmachado.cloud nfs-server
EOF

## Configuração dos parametros do sysctl
echo "[TASK 3] Enable sysctl parameters"
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

sudo apt-get update  > /dev/null 2>&1 && \
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    nfs-common \
    apt-transport-https -y

## Adicionando a chave GPG
echo "[TASK 4] Install GPG key - Docker"
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --no-tty --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg
sudo chmod a+r /etc/apt/trusted.gpg.d/docker.gpg

# Configurando o repositório
echo "[TASK 5] Add repository - Docker"
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/trusted.gpg.d/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

## Download da chave pública do kubernetes Debian
echo "[TASK 6] Install GPG Key - Kubernetes"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --no-tty --dearmor -o /etc/apt/trusted.gpg.d/kubernetes-apt-keyring.gpg

## Adiciona repositorio APT
echo "[TASK 7] Add repository"
echo 'deb [signed-by=/etc/apt/trusted.gpg.d/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list


## Instala containerd
echo "[TASK 9] Install containerd"
sudo apt-get update
sudo apt-get install -y containerd.io

## Configuração padrão do Containerd
echo "[TASK 10] Set containerd default configuration"
sudo mkdir -p /etc/containerd && containerd config default | sudo tee /etc/containerd/config.toml

## Altera arquivo de configuração para configurar systemd cgroup driver
echo "[TASK 11] Enable cgroup driver in containerd and restart service"
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

sudo systemctl restart containerd

## Desabilitar SWAP
echo "[TASK 12] Disble SWAP"
sudo sed -i '/swap/d' /etc/fstab
sudo swapoff -a

## Instalação do kubeadm, kubelet and kubectl

## Atualiza e instala: kubelet, kubeadm, kubectl e mantém versão para não ser atualizada
echo "[TASK 13] Update apt and install kubeadm, kubectl and kubelet"
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

## Importa Token
echo "[TASK 14] Import Kubernetes token"
sudo chmod +x /tmp/k8s/kube-token.sh
sudo sh /tmp/k8s/kube-token.sh
sudo rm -rf /tmp/k8s/kube-token.sh
