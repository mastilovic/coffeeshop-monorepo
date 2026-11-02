# k3s bootstrap (single-node VM)

Turns a clean Linux VM (Debian, ≥4 CPU / 8 GB) into a cluster that can run the CoffeeShop staging overlay. Do **not** install Docker.

## 1. k3s

```bash
sudo ./install.sh
```

Installs k3s with **Traefik disabled** so Ingress stays `ingressClassName: nginx`. Re-running the script does not wipe workloads.

Copy kubeconfig for your login user (mode 0600):

```bash
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown "$USER:$USER" ~/.kube/config
chmod 600 ~/.kube/config
kubectl get nodes
```

Leave the Kubernetes API (`6443`) off the public internet. Application traffic uses 80/443 only. `install.sh` drops TCP 6443 on the **public NIC only** so cluster pods (local-path, etc.) can still reach the API.

## 2. Firewall

On the **provider panel** (and host firewall if you enable one), allow inbound TCP **22, 80, 443**. Do **not** allow **6443**. Do not DROP 6443 from pod/service CIDRs (`10.42.0.0/16`, `10.43.0.0/16`); that breaks volume provisioning.

## 3. NGINX Ingress (`ingressClassName: nginx`)

k3s ServiceLB binds LoadBalancer services to the VM's public IP.

```bash
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```

If ports 80/443 do not show on the host (`ss -lnt | grep -E ':80|:443'`), retry with hostNetwork:

```bash
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.hostNetwork=true \
  --set controller.dnsPolicy=ClusterFirstWithHostNet
```

## 4. cert-manager

Same installer as every other cluster:

```bash
cd deploy/k8s/infra/cert-manager
chmod +x install.sh
./install.sh
```

HTTP-01 certificates become Ready only after DNS A records for the app and auth hosts point at this VM.

## 5. GHCR pull secret (only if packages are private)

```bash
kubectl create namespace coffeeshop-staging
kubectl create secret docker-registry ghcr-pull \
  --docker-server=ghcr.io \
  --docker-username=<github-username> \
  --docker-password=<github-pat-with-read:packages> \
  -n coffeeshop-staging
```

Then add `imagePullSecrets: [{name: ghcr-pull}]` on the Deployments, or skip this if GHCR packages are public.

## 6. Deploy the app

See [deploy/README.md](../../README.md). Staging overlay: `kubectl apply -k deploy/k8s/overlays/staging`.

Local-path volumes live on this disk. Restore means restore a **VM backup**, not a kubectl trick.
