# Installation procedure

# Active br_netfilter 
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

# Install docker from repository
sudo apt-get install --yes \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
    
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
sudo apt-get update
sudo apt-get install --yes docker-ce docker-ce-cli containerd.io

# Installation of kubadm kubelet kubectl

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker

# local docker-registry
mkdir -p /etc/docker/certs.d/docker-registry.lan/

echo "-----BEGIN CERTIFICATE-----
MIIFuTCCA6GgAwIBAgIUG0DLDfX2reKE+5LAt8q57SjtaOcwDQYJKoZIhvcNAQEL
BQAwXDELMAkGA1UEBhMCRlIxETAPBgNVBAgMCFl2ZWxpbmVzMQ4wDAYDVQQHDAVQ
YXJpczEMMAoGA1UECgwDbGFuMRwwGgYDVQQDDBNkb2NrZXItcmVnaXN0cnkubGFu
MB4XDTIxMDkwNzIxMTEzNVoXDTIyMDkwNzIxMTEzNVowXDELMAkGA1UEBhMCRlIx
ETAPBgNVBAgMCFl2ZWxpbmVzMQ4wDAYDVQQHDAVQYXJpczEMMAoGA1UECgwDbGFu
MRwwGgYDVQQDDBNkb2NrZXItcmVnaXN0cnkubGFuMIICIjANBgkqhkiG9w0BAQEF
AAOCAg8AMIICCgKCAgEAvMtHNptbU+bI67Ll70K+L04mMiGWuQU3HaAoG/iMs/Y4
UBkIg8sWx+Bl0SF5ToVTN9vTaWWdksdsKI6ZYYWjOpBNeUhlUhTa+Zq5DMXzjiG6
1wzxMh4SnlFwBcZCTw5RLH6njZx7bWPjF+YllI+OhoyomCpezlJS0ovqKvxqtkvN
twPF50X0PftOTpW+Zpt8eObcEfE6CEUL0r0u7pGJXm5W1oKHA9s8UWyieO5VzHER
d2qlMynvrSqvru+r+66fyaxLXFpcFgZRrb9c4R2QRYLs2YizEPoUomYwmgT5r1nn
1ePJ1VrJV5DyddmyRoCwyrzELCoV4OMaqLGO/uTcF5cXFVsoCC5cq4SseKJGyRJs
am2EmMTKh5TdknAAYT8ucv88W85rl58LsuW+5iPUde08kBfmze026wk0/0XGLKoG
UAC7d2Z6n0Wxyvl79KfXugjurBg5Qt7Zj76Kda+rA7OJc9y+cUBCZhFr0pwSvz51
KNVWEnUxwCX9jnlM+K5vdT4TJqtxN7cJbtnf7mI8622LtBLR7gvk80XUwP0reIGE
TfktQqzKB4W+Gbq6v6h0BCIWSI8qGg4gh5T7HHUSGvKgLd/3CjYRbfR7+CYFCdyh
CVaCa2j3EH5J0p66atbdmlKYAw+oIVIodhsTfVlr3djNXAq5Z1qssX1cCF+PjecC
AwEAAaNzMHEwHQYDVR0OBBYEFHvyQZzhxw+m716a0dYwrM8Xq6QQMB8GA1UdIwQY
MBaAFHvyQZzhxw+m716a0dYwrM8Xq6QQMA8GA1UdEwEB/wQFMAMBAf8wHgYDVR0R
BBcwFYITZG9ja2VyLXJlZ2lzdHJ5LmxhbjANBgkqhkiG9w0BAQsFAAOCAgEARbHZ
tQ0lXfDxSKPi5jWMlxsWLIGTM92U1TiWUcVFUZvp25xd8qC2Rg3hep4TVvYYKccA
1GN0/5tNyfQjlEN41/pv7X36Fr1PdVN/RPpvPOoaGT2iCETMoD0Xv81juADebkB5
oNoI1xAvtJiHhJyk4boDq0zSY5m16mHKyYP7Mm46gegZgdm20AFhVY7flvgw/BNN
ru/nCHnzd9CMO//ufrm5S+l8rwLHAaRK/ED/TXTzyuU9cLBJ3aJD7cXSUrCweb2r
CURVpzLak8XWNcHpQKMVvzJw79Y0/vSCH91GFMPu19T3h3PLpRT950Jz6hdxWbjW
EGJGoQvWP/fBuHo4aleZLKyiuHz7Rt4sDmRXJa650jOBq9sCqSmFVVve9Rs+XHTf
nyAuaqc2jtkZIUddeSpOZt9ThcWDbHKpS5wBGT6vCMyQGkF3cHzq8ymeUCqDkX85
qabfJmUARnE/K4mHCSvj+fWrORBaIJsSE6EBa1oatuMJi03GzLNkpeFlbaJ5d71n
8i6KsaH2aW3BbBOvEQaycVYAzDlNqm+iqmp26weweQOdQq7glCFwL1weL/fGCtl4
P47oWAhIpZ6beKuCzbjvEbt1lEnS+StxQGNaf464U20nCVLnmMBvgfV0QYaO9aPh
8yBczZLvvHU25B22bcyByCZoc5U28x/41/bE9QA=
-----END CERTIFICATE-----" | tee -a /etc/docker/certs.d/docker-registry.lan/ca.crt
