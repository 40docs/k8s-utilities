# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the **k8s-utilities** repository - a containerized toolkit containing essential Kubernetes utilities including kubectl v1.30.6 and jq for JSON processing. It's part of the larger 40docs platform ecosystem and serves as a standardized utility container for Kubernetes operations.

## Architecture

### Container Design
- **Base Image**: Ubuntu 22.04 LTS for stability and security
- **Core Tools**: 
  - kubectl v1.30.6 (fixed version for consistency)
  - jq for JSON parsing and manipulation
  - Standard CA certificates and curl for API operations

### Build System
- **Docker**: Single Dockerfile builds the complete utility container
- **GitHub Actions**: Automated container build and push to GitHub Container Registry (ghcr.io)
- **Registry**: Images published as `ghcr.io/{owner}/k8s-utilities:latest`

## Common Development Commands

### Container Operations
```bash
# Build container locally
docker build -t k8s-utilities .

# Run container interactively
docker run -it k8s-utilities /bin/bash

# Run with kubectl access (mount kubeconfig)
docker run -it -v ~/.kube:/root/.kube k8s-utilities

# Test kubectl functionality
docker run --rm k8s-utilities kubectl version --client
```

### GitHub Actions Workflow
- **Trigger**: Automatic on push to main branch or Dockerfile changes
- **Manual**: `workflow_dispatch` for on-demand builds
- **Registry**: Pushes to GitHub Container Registry with proper permissions
- **Concurrency**: Cancels in-progress builds when new commits pushed

### Development Workflow
```bash
# Test changes locally first
docker build -t k8s-utilities-test .
docker run --rm k8s-utilities-test kubectl version --client
docker run --rm k8s-utilities-test jq --version

# Validate Dockerfile changes
docker build --no-cache .

# Check for security vulnerabilities
docker scout cves k8s-utilities
```

## Integration with 40docs Platform

### Purpose in Ecosystem
- Provides consistent kubectl version across all platform operations
- Used in CI/CD pipelines for Kubernetes deployments
- Standardizes tooling for infrastructure automation scripts
- Enables portable Kubernetes operations across different environments

### Usage Patterns
- **Infrastructure Scripts**: Called by Terraform and automation scripts
- **CI/CD Pipelines**: Used in GitHub Actions workflows for deployments
- **Development**: Provides consistent tooling for developers across platforms
- **Orchestration**: Used by the 40docs orchestrator system for multi-repository operations

## Security Considerations

### Container Security
- Non-root execution recommended for production use
- No secrets or credentials embedded in container
- Minimal package installation to reduce attack surface
- Uses official Kubernetes kubectl binary

### Best Practices
- Mount kubeconfig securely rather than embedding
- Use specific kubectl version to avoid compatibility issues
- Regularly update base image for security patches
- Scan container images for vulnerabilities before deployment

## Coding Guidelines

### Dockerfile Standards
- Use specific versions for reproducible builds
- Minimize layers and clean up package caches
- Install only essential packages
- Document all installation steps with comments

### Security Requirements
- Never include kubeconfig files or cluster secrets in the container
- Use multi-stage builds if adding more complex tooling
- Implement proper user permissions for production deployment
- Validate all downloaded binaries with checksums when possible

## Container Usage Examples

### Basic Kubernetes Operations
```bash
# List pods in current namespace
docker run --rm -v ~/.kube:/root/.kube k8s-utilities kubectl get pods

# Get cluster info
docker run --rm -v ~/.kube:/root/.kube k8s-utilities kubectl cluster-info

# Process JSON output with jq
docker run --rm -v ~/.kube:/root/.kube k8s-utilities \
  bash -c "kubectl get pods -o json | jq '.items[].metadata.name'"
```

### Integration with Automation
```bash
# Use in shell scripts
KUBE_IMAGE="ghcr.io/owner/k8s-utilities:latest"
docker run --rm -v ~/.kube:/root/.kube $KUBE_IMAGE kubectl apply -f manifest.yaml

# Batch operations
docker run --rm -v ~/.kube:/root/.kube -v $(pwd):/workspace k8s-utilities \
  bash -c "cd /workspace && kubectl apply -f *.yaml"
```

## Troubleshooting

### Common Issues
- **Permission Denied**: Ensure kubeconfig has proper permissions (600)
- **Version Mismatch**: Container uses kubectl v1.30.6 - verify cluster compatibility
- **Network Issues**: Check if container can reach Kubernetes API server
- **Mount Issues**: Verify kubeconfig volume mount path and permissions

### Debugging
```bash
# Check container contents
docker run --rm k8s-utilities ls -la /usr/local/bin/

# Test connectivity
docker run --rm -v ~/.kube:/root/.kube k8s-utilities kubectl cluster-info

# Inspect kubeconfig
docker run --rm -v ~/.kube:/root/.kube k8s-utilities \
  bash -c "ls -la /root/.kube/ && cat /root/.kube/config"
```