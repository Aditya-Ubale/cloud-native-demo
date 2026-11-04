# Cloud-Native Demo App (Activity 1)
**Name:** Aditya Ubale | **PRN:** 202301040111

Flask app -> Docker image -> Kubernetes Deployment (3 replicas) + NodePort Service.

## Run
```bash
cd app && docker build -t <dockerhub-user>/cloud-demo:1.0 . && docker run -d -p 5000:5000 <dockerhub-user>/cloud-demo:1.0
kubectl apply -f k8s/deployment.yaml -f k8s/service.yaml
```
Or run everything step by step: `DOCKER_USER=<dockerhub-user> ./run_all.sh`
Endpoints: `/`, `/health`, `/api/info`

## Run without installing anything
Push this repo to GitHub -> **Actions** tab -> "Docker and Kubernetes Demo". The workflow builds the image,
runs the container, creates a kind cluster, deploys the manifests and prints all outputs.
