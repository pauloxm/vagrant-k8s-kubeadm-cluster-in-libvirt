#!/bin/bash

## Instalação dos módulos do Kernel
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter


## Configuração dos parametros do sysctl
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

## Instalação de pré requisitos

sudo apt update && \
sudo apt install \
    ca-certificates \
    curl \
    gnupg -y

## Adicionando a chave GPG

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Configurando o repositório

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

## Atualizando o repositório

sudo apt-get update

## Instala containerd

sudo apt update && sudo apt install -y containerd.io -y

## Configuração padrão do Containerd

sudo mkdir -p /etc/containerd && containerd config default | sudo tee /etc/containerd/config.toml

## Altera arquivo de configuração para configurar systemd cgroup driver

sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

sudo systemctl restart containerd

## Desabilitar SWAP
sudo sed -i '/swap/d' /etc/fstab
sudo swapoff -a


## Instalação do kubeadm, kubelet and kubectl

sudo apt-get update && \
sudo apt-get install -y apt-transport-https ca-certificates curl

## Download da chave pública do kubernetes Debian

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

## Adiciona repositorio APT

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list


## Atualiza e instala: kubelet, kubeadm, kubectl e mantém versão para não ser atualizada

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl


