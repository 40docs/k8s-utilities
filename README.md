# Kubernetes Utilities Container

A standardized containerized toolkit containing essential Kubernetes utilities for the 40docs platform ecosystem.

## Overview

This repository provides a Docker container with pre-installed Kubernetes tools, ensuring consistent tooling across development environments, CI/CD pipelines, and infrastructure automation scripts.

### Included Tools

- **kubectl v1.30.6** - Kubernetes command-line tool (fixed version for consistency)
- **jq** - JSON processor for parsing kubectl output
- **curl** - HTTP client for API operations
- **ca-certificates** - Standard certificate authorities

## Quick Start

### Pull and Run

```bash
# Pull the latest image
docker pull ghcr.io/rmordasiewicz/k8s-utilities:latest

# Run interactively
docker run -it ghcr.io/rmordasiewicz/k8s-utilities:latest

# Run with kubectl access (mount your kubeconfig)
docker run -it -v ~/.kube:/root/.kube ghcr.io/rmordasiewicz/k8s-utilities:latest
```

### Basic Usage Examples

```bash
# Check kubectl version
docker run --rm ghcr.io/rmordasiewicz/k8s-utilities:latest kubectl version --client

# List pods (requires kubeconfig)
docker run --rm -v ~/.kube:/root/.kube ghcr.io/rmordasiewicz/k8s-utilities:latest kubectl get pods

# Parse JSON output with jq
docker run --rm -v ~/.kube:/root/.kube ghcr.io/rmordasiewicz/k8s-utilities:latest \
  bash -c "kubectl get pods -o json | jq '.items[].metadata.name'"
```

## Development

### Building Locally

```bash
# Clone the repository
git clone https://github.com/rmordasiewicz/k8s-utilities.git
cd k8s-utilities

# Build the container
docker build -t k8s-utilities .

# Test the build
docker run --rm k8s-utilities kubectl version --client
docker run --rm k8s-utilities jq --version
```

### Container Structure

```dockerfile
FROM ubuntu:22.04

# Core utilities
- ca-certificates
- curl 
- apt-transport-https
- gnupg

# Kubernetes tools
- kubectl v1.30.6 (official binary from dl.k8s.io)
- jq (latest from Ubuntu repositories)
```

## Automation & CI/CD

### GitHub Actions Integration

This repository includes automated container builds via GitHub Actions:

- **Triggers**: Push to main branch, Dockerfile changes, manual dispatch
- **Registry**: Publishes to GitHub Container Registry (ghcr.io)
- **Tagging**: Latest tag for each successful build
- **Security**: Uses GitHub token authentication

### Usage in Scripts

```bash
#!/bin/bash
KUBE_IMAGE="ghcr.io/rmordasiewicz/k8s-utilities:latest"

# Apply Kubernetes manifests
docker run --rm -v ~/.kube:/root/.kube -v $(pwd):/workspace $KUBE_IMAGE \
  kubectl apply -f /workspace/manifests/

# Get cluster information
CLUSTER_INFO=$(docker run --rm -v ~/.kube:/root/.kube $KUBE_IMAGE \
  kubectl cluster-info --short)

echo "Cluster: $CLUSTER_INFO"
```

### Integration with 40docs Platform

This container is used throughout the 40docs platform for:

- **Infrastructure Scripts**: Terraform provisioning and validation
- **CI/CD Pipelines**: Automated deployments via GitHub Actions
- **Development Tools**: Consistent kubectl version across team members
- **Orchestration**: Multi-repository operations via Claude orchestrator system

## Security

### Best Practices

- **No Embedded Secrets**: Never includes kubeconfig files or credentials
- **Minimal Surface**: Only essential packages installed
- **Fixed Versions**: kubectl version pinned for reproducibility
- **Regular Updates**: Base image updated for security patches

### Secure Usage

```bash
# Recommended: Mount kubeconfig with proper permissions
chmod 600 ~/.kube/config
docker run --rm -v ~/.kube:/root/.kube:ro k8s-utilities kubectl get nodes

# For CI/CD: Use service account tokens or workload identity
docker run --rm -e KUBECONFIG=/tmp/kubeconfig \
  -v /path/to/service-account:/tmp/kubeconfig:ro \
  k8s-utilities kubectl apply -f manifest.yaml
```

## Troubleshooting

### Common Issues

**Permission Denied on kubeconfig**
```bash
# Fix kubeconfig permissions
chmod 600 ~/.kube/config
```

**kubectl version mismatch**
```bash
# Check server compatibility (container uses kubectl v1.30.6)
docker run --rm -v ~/.kube:/root/.kube k8s-utilities kubectl version
```

**Container networking issues**
```bash
# Test connectivity to Kubernetes API
docker run --rm -v ~/.kube:/root/.kube k8s-utilities \
  kubectl cluster-info
```

### Debug Container

```bash
# Explore container contents
docker run --rm k8s-utilities ls -la /usr/local/bin/

# Check installed packages
docker run --rm k8s-utilities dpkg -l

# Interactive debugging
docker run -it k8s-utilities /bin/bash
```

## Contributing

### Development Workflow

1. Make changes to Dockerfile
2. Test locally: `docker build -t k8s-utilities-test .`
3. Validate functionality: `docker run --rm k8s-utilities-test kubectl version --client`
4. Submit pull request
5. Automated build triggers on merge to main

### Guidelines

- Maintain kubectl version consistency
- Keep container minimal and secure
- Test changes against active Kubernetes clusters
- Document any breaking changes

## License

This project is part of the 40docs platform ecosystem. See the main repository for license information.

## Support

For issues related to:
- Container functionality: File an issue in this repository
- Integration with 40docs platform: See main 40docs repository
- kubectl usage: Refer to official Kubernetes documentation