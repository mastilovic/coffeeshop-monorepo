#!/usr/bin/env bash
# Install (or re-install) k3s with Traefik disabled.
# Idempotent: the official installer is safe to re-run and does not wipe workloads.
# Do not install Docker; k3s ships containerd.
set -euo pipefail

if [[ "$(id -u)" -ne 0 ]]; then
  echo "error: run as root (sudo $0)" >&2
  exit 1
fi

if command -v docker >/dev/null 2>&1; then
  echo "warning: Docker is present. k3s uses containerd; do not install Docker for this cluster." >&2
fi

export INSTALL_K3S_SKIP_START=false
curl -sfL https://get.k3s.io | sh -s - --disable traefik --write-kubeconfig-mode 644

# Block the API on the public NIC only. Do not DROP 6443 from 10.42/10.43 —
# local-path and other pods talk to the API via the cluster service DNAT.
install -m 0755 /dev/stdin /usr/local/sbin/coffeeshop-block-k3s-api.sh <<'EOS'
#!/usr/bin/env bash
set -euo pipefail
PUB_IF=$(ip -4 route get 1.1.1.1 | awk '{for(i=1;i<=NF;i++) if($i=="dev") {print $(i+1); exit}}')
add_if_missing() {
  local bin="$1"; shift
  if ! "$bin" -C "$@" >/dev/null 2>&1; then
    "$bin" -I "$@"
  fi
}
add_if_missing iptables INPUT -i "$PUB_IF" -p tcp --dport 6443 -j DROP
add_if_missing ip6tables INPUT -i "$PUB_IF" -p tcp --dport 6443 -j DROP || true
EOS
cat >/etc/systemd/system/coffeeshop-k3s-api-fw.service <<'UNIT'
[Unit]
Description=Block public access to k3s API port 6443
After=network-pre.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/sbin/coffeeshop-block-k3s-api.sh

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now coffeeshop-k3s-api-fw.service

# Wait until the node is Ready (first install or re-run).
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
for _ in $(seq 1 60); do
  if kubectl get nodes --no-headers 2>/dev/null | grep -q ' Ready '; then
    kubectl get nodes
    echo "k3s is Ready. Kubeconfig: /etc/rancher/k3s/k3s.yaml"
    echo "For a non-root user: mkdir -p ~/.kube && sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config && sudo chown \"\$USER:\$USER\" ~/.kube/config && chmod 600 ~/.kube/config"
    exit 0
  fi
  sleep 2
done

echo "error: k3s node did not become Ready" >&2
kubectl get nodes || true
exit 1
