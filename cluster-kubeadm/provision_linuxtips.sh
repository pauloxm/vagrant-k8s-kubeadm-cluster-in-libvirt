#!/bin/bash

# LinuxTips - Descomplicando K8S

## Instalação do Container Rubtime (Containerd)

# Instalação dos módulos do Kernel
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Configuração dos parâmetros do sysctl
# Configuração dos parâmetros do sysctl, fica mantido mesmo com reebot da máquina.
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Aplica as definições do sysctl sem reiniciar a máquina
sudo sysctl --system

# Atualizando o repositório

sudo apt-get update

# Instalando Containerd

sudo apt update && sudo apt install -y containerd -y

# Configurar containerd gerando arquivo de configuração

mkdir -p /etc/containerd

containerd config default > /etc/containerd/config.toml

systemctl restart containerd

## Instalação do kubeadm, kubelet and kubectl

sudo apt-get update && \
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/trusted.gpg.d/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Instalar versão específica do Kubernetes

sudo apt-get update && \
sudo apt-get install -y kubelet kubeadm kubectl

# Configurar CRI

export CONTAINER_RUNTIME_ENDPOINT=unix:///run/containerd/containerd.sock
