# GitHub Actions Build Setup for BGShellBB10

This document explains the automated build system for BGShellBB10 using Docker.

## Overview

This project uses GitHub Actions with a pre-built Docker image (`sw7ft/bb10-gcc9:latest`) that contains the complete BlackBerry 10 NDK toolchain.

**Two workflows:**
1. **Build Workflow** (`.github/workflows/docker-build.yml`) - Builds on push/PR
2. **Release Workflow** (`.github/workflows/release.yml`) - Creates releases with BAR files

## How It Works

### Docker Image

The build uses `sw7ft/bb10-gcc9:latest` which includes:
- BlackBerry 10 NDK 10.3.1.995
- Complete build toolchain
- All required dependencies
- Pre-configured environment

**Environment setup in the image:**
- BB10 environment: `/root/bbndk/bbndk-env_10_3_1_995.sh`
- Locale: `LC_ALL=C`

### Automated Builds

Every push to `master`, `main`, or `develop` branches triggers:
1. Pull the Docker image
2. Prepare build files (copy from `_*.pro`, `_*.xml`)
3. Build inside Docker container
4. Generate Device-Release.bar
5. Upload build artifacts

### Automated Releases

Creating a git tag triggers the release workflow:
1. Build the BAR file in Docker
2. Create source archive
3. Generate release notes
4. Publish GitHub release with:
   - BAR installation package
   - Source code ZIP

## Creating a Release

```bash
# 1. Update version in _bar-descriptor.xml
# <versionNumber>0.0.2</versionNumber>
# <buildId>1</buildId>

# 2. Commit changes
git add _bar-descriptor.xml
git commit -m "Bump version to 0.0.2.1"
git push

# 3. Create and push tag
git tag -a v0.0.2.1 -m "Release v0.0.2.1"
git push origin v0.0.2.1
```

The release will automatically include the built BAR file!

## Local Development

### Using Docker (Recommended)

Build locally using the same Docker image:

```bash
# Pull the image
docker pull sw7ft/bb10-gcc9:latest

# Prepare files
cp _BGShellBB10.pro BGShellBB10.pro
cp _bar-descriptor.xml bar-descriptor.xml
cp _Makefile Makefile

# Build in Docker
docker run --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  sw7ft/bb10-gcc9:latest \
  bash -c "source /root/bbndk/bbndk-env_10_3_1_995.sh && \
           export LC_ALL=C && \
           make clean && \
           make Device-Release && \
           make Device-Release.bar"

# Your BAR file will be at Device-Release.bar
```

### Using the build script

```bash
# The build.sh script can be adapted for Docker
./build.sh release
```

## Workflow Files

### docker-build.yml
**Purpose:** Continuous integration builds on every push

**Triggers:**
- Push to master/main/develop
- Pull requests
- Manual workflow dispatch

**Output:** Build artifacts uploaded to GitHub Actions

### release.yml
**Purpose:** Create GitHub releases with BAR packages

**Triggers:**
- Tags matching: `v*.*.*`, `[0-9]+.[0-9]+.[0-9]+`, `release-*`
- Manual workflow dispatch

**Output:** 
- GitHub release with BAR file
- Source code archive
- Auto-generated release notes

## Checking Build Status

```bash
# View recent builds
gh run list --repo QNXcraft/BGShellBB10 --limit 5

# View specific run
gh run view RUN_ID --repo QNXcraft/BGShellBB10 --log

# Download build artifacts
gh run download RUN_ID --repo QNXcraft/BGShellBB10
```

## Troubleshooting

### Docker pull fails
The image is publicly available on Docker Hub. If you can't pull it:
```bash
docker pull sw7ft/bb10-gcc9:latest
```

### Build fails in Docker
Check the workflow logs:
```bash
gh run view --log-failed --repo QNXcraft/BGShellBB10
```

Common issues:
- **Permissions**: Docker needs write access to workspace
- **File paths**: Ensure `_*.pro`, `_*.xml` files exist
- **Makefile errors**: Check Makefile syntax

### BAR file not created
Verify build completed successfully:
```bash
ls -la Device-Release.bar
ls -la arm/o.le-v7/BGShellBB10
```

## Additional Information

### Docker Image Details
- **Image:** `sw7ft/bb10-gcc9:latest`
- **NDK Version:** 10.3.1.995
- **Base:** Ubuntu with Momentics IDE
- **Environment:** Pre-configured with all BB10 build tools

### No Setup Required!
Unlike traditional CI/CD, you don't need to:
- Install or configure BB10 NDK
- Set up environment variables
- Download large SDK files
- Configure build tools

Everything is included in the Docker image.

## Support

- **Build issues:** Check workflow logs in GitHub Actions
- **Docker issues:** Verify image is accessible: `docker pull sw7ft/bb10-gcc9:latest`
- **Application issues:** Email support@bgmot.com

## Links

- Docker Image: https://hub.docker.com/r/sw7ft/bb10-gcc9
- Actions: https://github.com/QNXcraft/BGShellBB10/actions
- Releases: https://github.com/QNXcraft/BGShellBB10/releases
