# BGShellBB10 - Automated Build & Release Guide

## 🚀 What's Changed

Your project now has **fully automated Docker-based builds** - no BB10 NDK installation required!

### Active Workflows

1. **Build Workflow** (`.github/workflows/docker-build.yml`)
   - Triggers on every push to master/main/develop
   - Builds BAR file using Docker
   - Uploads artifacts

2. **Release Workflow** (`.github/workflows/release.yml`) 
   - Triggers on git tags (v0.0.1 or 0.0.1 format)
   - Builds BAR file
   - Creates GitHub release with BAR + source

## 📦 Creating Releases with BAR Files

Now your releases will **automatically include the BAR installation file**!

```bash
# 1. Update version in _bar-descriptor.xml
#    <versionNumber>0.0.2</versionNumber>
#    <buildId>1</buildId>

# 2. Commit and push
git add _bar-descriptor.xml
git commit -m "Bump version to 0.0.2.1"
git push

# 3. Create release tag
git tag -a v0.0.2.1 -m "Release v0.0.2.1"
git push origin v0.0.2.1

# 4. GitHub Actions will automatically:
#    - Build Device-Release.bar in Docker
#    - Create source archive
#    - Publish release with both files
```

Check your release at: https://github.com/QNXcraft/BGShellBB10/releases

## 🐳 Docker-Based Build

Uses `sw7ft/bb10-gcc9:latest` which includes:
- BB10 NDK 10.3.1.995
- Complete build toolchain
- All dependencies

**No setup required** - everything runs in Docker!

## 💻 Local Development

### Build locally with Docker:

```bash
# Just run the build script
./build.sh release

# Other options:
./build.sh debug      # Debug build
./build.sh simulator  # Simulator build
./build.sh all        # Build everything
./build.sh clean      # Clean artifacts
```

Requirements: Docker installed

### Manual Docker build:

```bash
# Pull image
docker pull sw7ft/bb10-gcc9:latest

# Build
docker run --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  sw7ft/bb10-gcc9:latest \
  bash -c "source /root/bbndk/bbndk-env_10_3_1_995.sh && \
           export LC_ALL=C && \
           cp _BGShellBB10.pro BGShellBB10.pro && \
           cp _bar-descriptor.xml bar-descriptor.xml && \
           cp _Makefile Makefile && \
           make clean && \
           make Device-Release && \
           make Device-Release.bar"

# Result: Device-Release.bar
```

## 📊 Monitoring Builds

```bash
# View recent builds
gh run list --repo QNXcraft/BGShellBB10

# View specific run
gh run view RUN_ID --log

# Download artifacts
gh run download RUN_ID
```

## 🔍 What Was Removed

To streamline the setup, these files were removed:
- ❌ `.github/workflows/build.yml` (merged into docker-build.yml)
- ❌ `.github/workflows/upload-bar.yml` (no longer needed)
- ❌ `Dockerfile.bb10` (using pre-built sw7ft/bb10-gcc9:latest)

## ✅ What You Have Now

- ✅ Automated BAR builds in CI/CD
- ✅ Docker-based builds (no NDK install needed)
- ✅ GitHub Releases with BAR files
- ✅ Local build script using same Docker image
- ✅ Clean, maintainable workflow

## 📝 Next Steps

1. **Test the build workflow:**
   - Make a small change and push
   - Check Actions tab: https://github.com/QNXcraft/BGShellBB10/actions
   - Verify BAR file is created

2. **Create a new release:**
   - Update version in `_bar-descriptor.xml`
   - Create and push a tag
   - Verify release includes BAR file

3. **Build locally:**
   - Run `./build.sh release`
   - Install Docker if needed

## 🐛 Troubleshooting

### Build fails in Docker
```bash
# Check if Docker is running
docker ps

# Pull image manually
docker pull sw7ft/bb10-gcc9:latest

# View workflow logs
gh run view --log-failed
```

### Release doesn't trigger
- Ensure tag format: `v0.0.1` or `0.0.1` or `release-0.0.1`
- Check Actions tab for errors

### BAR file not included in release
- Check workflow logs for build errors
- Verify `_bar-descriptor.xml` is valid XML
- Ensure Makefile targets exist

## 📚 Documentation

- **BUILD_SETUP.md** - Detailed build documentation
- **RELEASE_GUIDE.md** - Release creation guide  
- **GITHUB_ACTIONS_SUMMARY.md** - Workflow overview

## 🎉 Benefits

**Before:**
- ❌ Manual NDK installation required
- ❌ Platform-specific setup
- ❌ No automated BAR builds
- ❌ Manual release uploads

**After:**
- ✅ Zero setup (Docker handles everything)
- ✅ Works on any platform
- ✅ Automatic BAR file creation
- ✅ One command to release

---

**Docker Image:** https://hub.docker.com/r/sw7ft/bb10-gcc9  
**Actions:** https://github.com/QNXcraft/BGShellBB10/actions  
**Releases:** https://github.com/QNXcraft/BGShellBB10/releases
