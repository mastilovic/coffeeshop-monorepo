# Spec Delta

## Purpose

Turns a clean Linux virtual machine into a single-node Kubernetes cluster that can run CoffeeShop with local disks and public HTTP/HTTPS on the machine's own address, without a managed cloud control plane.

## ADDED Requirements

### Requirement: Repeatable cluster bootstrap for a clean VM

The repository SHALL provide a documented, idempotent bootstrap that, on a supported Linux VM with at least 4 CPUs and 8 GB of RAM, produces a single-node Kubernetes cluster. After bootstrap, `kubectl` against that cluster SHALL report the node Ready. The bootstrap SHALL be usable on a later VM of the same class without copying cluster-specific secrets from the first machine.

#### Scenario: Empty Debian VM becomes a Ready cluster

- **WHEN** an operator runs the documented bootstrap on a clean Debian VM with 4 CPUs and 8 GB of RAM
- **THEN** the node is Ready and the operator can run `kubectl get nodes` using a kubeconfig that lives on the machine

#### Scenario: Bootstrap can be re-run

- **WHEN** the operator runs the same bootstrap a second time on a cluster that is already Ready
- **THEN** the command completes without destroying existing workloads or requiring a wipe

### Requirement: Ingress listens on the VM public address

The cluster SHALL accept HTTP on TCP 80 and HTTPS on TCP 443 on the VM's public IPv4 address, using ingress class `nginx` so existing CoffeeShop Ingress objects apply without changing their class. The Kubernetes API port SHALL NOT be required to be reachable from the public internet for the application to serve traffic.

#### Scenario: Ports 80 and 443 reach ingress

- **WHEN** the host firewall and provider firewall allow TCP 80 and 443 to the VM
- **THEN** an Ingress with class `nginx` is reachable at the VM public IP on those ports

#### Scenario: Application traffic does not need a public API server

- **WHEN** TCP 6443 is blocked from the internet and TCP 80/443 are open
- **THEN** HTTP/HTTPS application traffic to ingress still succeeds

### Requirement: Default storage provisions in-cluster volumes

Workloads that request persistent volumes without naming a cloud StorageClass SHALL receive bound volumes on the VM's local disk. Two 5 Gi claims (application Postgres and Keycloak Postgres) SHALL be able to bind at the same time.

#### Scenario: Unclassed PVC binds

- **WHEN** a PersistentVolumeClaim requests 5Gi ReadWriteOnce and omits storageClassName
- **THEN** the claim becomes Bound on local disk

#### Scenario: Both database claims bind

- **WHEN** the CoffeeShop staging overlay is applied
- **THEN** both Postgres volume claims become Bound

### Requirement: Certificate controller is installable on the cluster

The existing cert-manager install path SHALL work on the bootstrapped cluster (ClusterIssuers for Let's Encrypt HTTP-01 with ingress class `nginx`). After DNS for the application hosts points at the VM, the CoffeeShop TLS secret SHALL be able to become Ready without a cloud load balancer.

#### Scenario: cert-manager install on the VM cluster

- **WHEN** an operator runs the documented cert-manager install against the VM cluster
- **THEN** cert-manager pods are Available and ClusterIssuers exist

#### Scenario: HTTP-01 certificate after DNS cutover

- **WHEN** app and auth host A records point at the VM public IP and the staging Ingress requests a certificate
- **THEN** the `coffeeshop-tls` certificate becomes Ready
