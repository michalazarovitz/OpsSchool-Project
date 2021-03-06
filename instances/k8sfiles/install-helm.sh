#!/usr/bin/env bash

wget https://get.helm.sh/helm-v3.0.2-linux-amd64.tar.gz
sudo tar xvf helm-v3.0.2-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/
git clone --single-branch --branch v0.8.1 https://github.com/hashicorp/consul-helm.git
kubectl create secret generic consul-gossip-encryption-key --from-literal=key="uDBV4e+LbFW3019YKPxIrg=="
tee /home/ubuntu/consul-helm/values.yaml > /dev/null <<EOF
global:
  enabled: false
  domain: consul
  image: "consul:1.4.0"
  imageK8S: "hashicorp/consul-k8s:0.8.1"
  datacenter: opsschool
  enablePodSecurityPolicies: false
  gossipEncryption:
    secretName: consul-gossip-encryption-key
    secretKey: key
  bootstrapACLs: false

server:
  enabled: "-"
  image: null
  replicas: 3
  bootstrapExpect: 3 # Should <= replicas count
  enterpriseLicense:
    secretName: null
    secretKey: null
  storage: 10Gi
  storageClass: null
  connect: true
  resources: null
  updatePartition: 0
  disruptionBudget:
    enabled: true
    maxUnavailable: null
  extraConfig: |
    {}
  extraVolumes: []
  affinity: |
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchLabels:
              app: {{ template "consul.name" . }}
              release: "{{ .Release.Name }}"
              component: server
          topologyKey: kubernetes.io/hostname
  tolerations: ""
  nodeSelector: null
  priorityClassName: ""
  annotations: null
  extraEnvironmentVars: {}
  
client:
  enabled: true
  image: null
  join: 
    - "provider=aws tag_key=consul_server tag_value=true"
  grpc: false
  exposeGossipPorts: true
  resources: null
  extraConfig: |
    {}
  extraVolumes: []
  tolerations: ""
  nodeSelector: null
  priorityClassName: ""
  annotations: null
  extraEnvironmentVars: {}
    

dns:
  enabled: true

ui:
  enabled: "-"
  service:
    enabled: true
    type: null
    annotations: null
    additionalSpec: null

syncCatalog:
  enabled: true
  image: null
  default: true 
  toConsul: true
  toK8S: true
  k8sPrefix: null
  consulPrefix: null
  k8sTag: null
  syncClusterIPServices: true
  nodePortSyncType: ExternalFirst
  aclSyncToken:
    secretName: null
    secretKey: null
  nodeSelector: null


connectInject:
  enabled: false
  image: null # image for consul-k8s that contains the injector
  default: false # true will inject by default, otherwise requires annotation
  imageConsul: null
  imageEnvoy: null
  namespaceSelector: null
  certs:
    secretName: null
    caBundle: ""
    certName: tls.crt
    keyName: tls.key

  nodeSelector: null
  aclBindingRuleSelector: "serviceaccount.name!=default"

 
  centralConfig:
    enabled: false
    defaultProtocol: null
    proxyDefaults: |
      {}
EOF
helm install hashicorp ./consul-helm

consul_dns_ip=$(kubectl get service/hashicorp-consul-dns -o jsonpath='{.spec.clusterIP}')

tee /home/ubuntu/core-dns.yaml > /dev/null <<EOF
apiVersion: v1
data:
  Corefile: |
    .:53 {
        errors
        health
        kubernetes cluster.local in-addr.arpa ip6.arpa {
          pods insecure
          upstream
          fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        forward . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
    }
    consul {
              errors
              cache 30
              forward . $consul_dns_ip
    }
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
EOF

kubectl replace -n kube-system -f /home/ubuntu/core-dns.yaml


## Prometheus
helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo update
kubectl create namespace monitoring
helm install prometheus --namespace monitoring stable/prometheus -f /home/ubuntu/k8sfiles/values.yaml
kubectl patch svc prometheus-server --namespace monitoring -p '{"spec": {"type": "LoadBalancer"}}'

#Deploy Filebeat to Kubernetes
kubectl create -f /home/ubuntu/k8sfiles/filebeat-kubernetes.yaml


