#!/usr/bin/env bash
# Activity 1 - one-shot demo script. Run from the project root (folder containing app/ and k8s/).
# It pauses after each step so you can take one clean screenshot per figure.
#   Usage:  DOCKER_USER=yourdockerhubname ./run_all.sh
set -u
DOCKER_USER="${DOCKER_USER:-adityaubale}"
IMAGE="$DOCKER_USER/cloud-demo:1.0"

banner(){ echo; echo "=============================================================="; echo "  $1"; echo "=============================================================="; }
pause(){ echo; read -r -p ">>> Take your screenshot now ($1). Press ENTER to continue... " _; }
run(){ echo "\$ $*"; "$@"; }

clear
echo "Name: Aditya Ubale   |   PRN: 202301040111"
echo "Activity 1: Containerization and Deployment of a Cloud-Native Application"
echo "Date: $(date)"
echo "Image: $IMAGE"
pause "Header / identity"

banner "FIGURE 3 - Build Docker image"
( cd app && run docker build -t "$IMAGE" . )
pause "Figure 3"

banner "FIGURE 4 - List image"
run docker images "$DOCKER_USER/cloud-demo"
pause "Figure 4"

banner "FIGURE 5 - Run container + logs"
docker rm -f cloud-demo >/dev/null 2>&1
run docker run -d --name cloud-demo -p 5000:5000 "$IMAGE"
sleep 3
run docker ps --filter name=cloud-demo
run docker logs cloud-demo
pause "Figure 5"

banner "FIGURE 6 - Test the container"
run curl -s localhost:5000/health; echo
run curl -s localhost:5000/api/info; echo
echo "(Also open http://localhost:5000 in a browser and screenshot it, with the address bar visible.)"
pause "Figure 6"
docker rm -f cloud-demo >/dev/null 2>&1

banner "FIGURE 7 - Kubernetes cluster"
if ! kubectl get nodes >/dev/null 2>&1; then
  if command -v minikube >/dev/null; then run minikube start --driver=docker
  elif command -v kind >/dev/null; then run kind create cluster
  else echo "No cluster found. Start one (minikube/kind/Docker Desktop Kubernetes/Killercoda) and rerun."; exit 1; fi
fi
run kubectl get nodes
pause "Figure 7"

# make the local image visible to the cluster
command -v minikube >/dev/null && minikube status >/dev/null 2>&1 && minikube image load "$IMAGE"
command -v kind >/dev/null && kind get clusters 2>/dev/null | grep -q . && kind load docker-image "$IMAGE"
sed "s#adityaubale/cloud-demo:1.0#$IMAGE#" k8s/deployment.yaml > /tmp/deployment.yaml

banner "FIGURE 8 - Apply manifests"
run kubectl apply -f /tmp/deployment.yaml
run kubectl apply -f k8s/service.yaml
pause "Figure 8"

banner "FIGURE 9 - Pods, deployment, service"
kubectl rollout status deployment/cloud-demo-deployment --timeout=120s
run kubectl get deployments
run kubectl get pods -o wide
run kubectl get svc
pause "Figure 9"

banner "FIGURE 10 - Access via Service"
if command -v minikube >/dev/null && minikube status >/dev/null 2>&1; then
  URL="$(minikube service cloud-demo-service --url | head -1)"; echo "Service URL: $URL"
else
  echo "Starting port-forward on http://localhost:8080 (background)"
  kubectl port-forward svc/cloud-demo-service 8080:80 >/dev/null 2>&1 &
  PF=$!; sleep 3; URL="http://localhost:8080"
fi
run curl -s "$URL/api/info"; echo
echo "(Open $URL in a browser and screenshot it with the address bar visible.)"
pause "Figure 10"

banner "FIGURE 11 - Load balancing + self-healing"
for i in 1 2 3 4 5 6; do curl -s "$URL/api/info" | grep -o '"hostname":"[^"]*"'; done
POD="$(kubectl get pods -l app=cloud-demo -o jsonpath='{.items[0].metadata.name}')"
run kubectl delete pod "$POD"
sleep 5
run kubectl get pods
pause "Figure 11"

banner "DONE - optional cleanup:  kubectl delete -f k8s/ ; docker rm -f cloud-demo"
[ -n "${PF:-}" ] && kill "$PF" 2>/dev/null
