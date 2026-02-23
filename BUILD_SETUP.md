# GitHub Actions Build Setup for BGShellBB10

This document explains how to set up and use GitHub Actions to automatically build and release BGShellBB10.

## Overview

This project includes two GitHub Actions workflows:

1. **Build Workflow** (`.github/workflows/build.yml`) - Automatically builds the project on push/PR
2. **Release Workflow** (`.github/workflows/release.yml`) - Creates GitHub releases with BAR packages

## Prerequisites

### BlackBerry 10 NDK Setup

Since BlackBerry 10 is a legacy platform, the NDK (Native Development Kit) is not available in standard CI environments. You have several options:

#### Option 1: Docker Container (Recommended)

Create a Docker image with BB10 NDK pre-installed:

```dockerfile
FROM ubuntu:18.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    unzip \
    libx11-6 \
    libxext6 \
    libxrender1

# Copy and install BB10 NDK
# You'll need to provide the NDK installer
COPY bbndk-*.run /tmp/
RUN chmod +x /tmp/bbndk-*.run && \
    /tmp/bbndk-*.run --silent && \
    rm /tmp/bbndk-*.run

ENV QNX_HOST=/path/to/ndk/host
ENV QNX_TARGET=/path/to/ndk/target
```

Then push this to Docker Hub or GitHub Container Registry and modify the workflow to use it.

#### Option 2: Self-Hosted Runner

Set up a self-hosted GitHub Actions runner on a machine with BB10 NDK installed:

1. Go to your GitHub repository → Settings → Actions → Runners
2. Click "New self-hosted runner"
3. Follow the setup instructions
4. Install BB10 NDK on that machine
5. Modify workflows to use: `runs-on: self-hosted`

#### Option 3: NDK in GitHub Releases

Store the BB10 NDK in a private/public GitHub release and download it during the workflow:

```yaml
- name: Download BB10 NDK
  run: |
    wget https://github.com/your-org/bb10-ndk/releases/download/v10.3.1/bbndk.tar.gz
    tar -xzf bbndk.tar.gz -C ~/bbndk
```

## Workflow Usage

### Build Workflow

Triggers automatically on:
- Push to `main`, `master`, or `develop` branches
- Pull requests to these branches
- Manual trigger via "Actions" tab

**What it does:**
- Checks out the code
- Sets up BB10 NDK (if configured)
- Builds the project
- Uploads build artifacts

### Release Workflow

Triggers on:
- Git tags matching `v*.*.*` (e.g., `v0.0.2.0`)
- Git tags matching `release-*`
- Manual trigger with custom tag name

**What it does:**
- Builds the release BAR package
- Creates source code archive
- Generates release notes
- Creates GitHub release with downloadable assets

## Creating a Release

### Method 1: Git Tags (Recommended)

```bash
# Create and push a tag
git tag -a v0.0.2.1 -m "Release version 0.0.2.1"
git push origin v0.0.2.1
```

### Method 2: Manual Trigger

1. Go to Actions tab in GitHub
2. Select "Create Release" workflow
3. Click "Run workflow"
4. Enter the tag name (e.g., `v0.0.2.1`)
5. Click "Run workflow"

## Configuration

### Updating Version Numbers

Before creating a release, update the version in `_bar-descriptor.xml`:

```xml
<versionNumber>0.0.2</versionNumber>
<buildId>1</buildId>
```

This will be automatically detected and included in the release.

### GitHub Secrets

No secrets are required for basic operation. However, you may need to add:

- `BB10_SIGNING_KEY` - If you want to sign the BAR files
- `BB10_SIGNING_PASSWORD` - Password for the signing key

## Customization

### Adding Signing to Releases

Modify the release workflow to include signing:

```yaml
- name: Sign BAR package
  env:
    SIGNING_PASSWORD: ${{ secrets.BB10_SIGNING_PASSWORD }}
  run: |
    blackberry-signer -storepass "$SIGNING_PASSWORD" \
      -keystore ~/.rim/author.p12 \
      Device-Release.bar
```

### Building for Simulator

Add simulator build to workflows:

```yaml
- name: Build Simulator
  run: |
    make Simulator-Debug
    make Simulator-Debug.bar
```

## File Structure

The workflows expect these files in the repository root:
- `_BGShellBB10.pro` - Qt project file
- `_bar-descriptor.xml` - BlackBerry descriptor
- `_Makefile` - Build makefile

These are automatically copied to their working names (without `_` prefix) during the build.

## Troubleshooting

### NDK Not Found

If you see "BB10 NDK not found" errors:
1. Check that the NDK is properly installed in the runner
2. Verify the path in the workflow matches your NDK location
3. Ensure `bbndk-env.sh` exists and is sourced correctly

### Build Failures

Common issues:
- Missing dependencies: Update the `apt-get install` section
- QNX compiler errors: Verify NDK version compatibility
- Permission issues: Ensure files have correct permissions

### Release Upload Failures

If release creation fails:
1. Verify you have write permissions on the repository
2. Check that the tag doesn't already exist
3. Ensure BAR file was built successfully

## Manual Build (Local)

To build locally with the same process:

```bash
# Prepare build files
cp _BGShellBB10.pro BGShellBB10.pro
cp _bar-descriptor.xml bar-descriptor.xml
cp _Makefile Makefile

# Source BB10 environment
source ~/bbndk/bbndk-env.sh

# Build
make clean
make Device-Release
make Device-Release.bar
```

## Additional Resources

- [BlackBerry 10 NDK Documentation](https://developer.blackberry.com/native/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [QTermWidget Project](http://qtermwidget.sourceforge.net/)

## Support

For issues specific to:
- **Build process**: Check this documentation and workflow files
- **BGShellBB10 application**: Email support@bgmot.com
- **GitHub Actions**: See GitHub Actions documentation

## License

This build configuration follows the same license as the main project (see COPYING file).
