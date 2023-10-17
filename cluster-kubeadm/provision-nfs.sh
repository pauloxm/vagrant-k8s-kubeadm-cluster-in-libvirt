# Update hosts file
echo "[TASK 1] Update /etc/hosts file"
cat >>/etc/hosts<<EOF
192.168.56.10 controlplane.example.com controlplane
192.168.56.20 worker01.example.com worker01
192.168.56.30 worker02.example.com worker02
192.168.56.40 worker03.example.com worker03
192.168.56.200 nfs.example.com nfs
EOF

echo "[TASK 2] Download and install NFS server"
apt-get update
apt-get install -y nfs-kernel-server rpcbind

echo "[TASK 3] Create a kubedata directory"
mkdir -p /srv/nfs/kubedata
mkdir -p /srv/nfs/kubedata/db
mkdir -p /srv/nfs/kubedata/storage
mkdir -p /srv/nfs/kubedata/logs

echo "[TASK 4] Download GLPI Files"
wget https://github.com/glpi-project/glpi/releases/download/10.0.10/glpi-10.0.10.tgz -O /tmp/glpi.tgz
tar -zxvf /tmp/glpi.tgz -C /tmp/
mv /tmp/glpi/* /srv/nfs/kubedata/storage/

echo "[TASK 5] Update the shared folder access"
chown nobody:nogroup /srv/nfs/kubedata
chmod -R 777 /srv/nfs/kubedata

echo "[TASK 6] Make the kubedata directory available on the network"
cat >>/etc/exports<<EOF
/srv/nfs/kubedata    *(rw,sync,no_subtree_check,no_root_squash)
EOF

echo "[TASK 7] Export the updates"
sudo exportfs -rav

echo "[TASK 8] Enable NFS Server"
sudo systemctl enable nfs-server

echo "[TASK 9] Start NFS Server"
sudo systemctl start nfs-server
