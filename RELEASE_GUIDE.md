# Quick Release Guide

## Creating a New Release

### Method 1: Using Git Tags (Automatic - Recommended for future)

The workflow now supports tags with OR without the 'v' prefix:

```bash
# Update version in _bar-descriptor.xml first
# <versionNumber>0.0.2</versionNumber>
# <buildId>1</buildId>

# Create and push tag (either format works)
git tag -a v0.0.2.1 -m "Release version 0.0.2.1"
# OR
git tag -a 0.0.2.1 -m "Release version 0.0.2.1"

# Push the tag
git push origin v0.0.2.1
# OR  
git push origin 0.0.2.1
```

The release workflow will automatically:
- Build (if BB10 NDK is configured)
- Create source archive
- Generate release notes
- Publish to GitHub Releases

### Method 2: Manual Trigger (For existing tags)

If you already created a tag or want to retry a release:

```bash
# Using GitHub CLI
gh workflow run release.yml --repo QNXcraft/BGShellBB10 --ref master -f tag_name=YOUR_TAG

# Example:
gh workflow run release.yml --repo QNXcraft/BGShellBB10 --ref master -f tag_name=0.0.1
```

Or use GitHub web interface:
1. Go to Actions tab
2. Select "Create Release" workflow
3. Click "Run workflow"
4. Enter tag name
5. Click "Run workflow" button

### Method 3: GitHub Web Interface

1. Go to: https://github.com/QNXcraft/BGShellBB10/releases
2. Click "Draft a new release"
3. Click "Choose a tag" → Create new tag
4. Enter tag name matching pattern:
   - `v0.0.2.1` (with v prefix)
   - `0.0.2.1` (without v prefix)
   - `release-0.0.2.1` (with release prefix)
5. Click "Generate release notes" (or write custom notes)
6. Click "Publish release"

This will trigger the workflow automatically.

## Checking Release Status

```bash
# View recent workflow runs
gh run list --repo QNXcraft/BGShellBB10 --workflow=release.yml --limit 5

# View specific run details
gh run view RUN_ID --repo QNXcraft/BGShellBB10 --log

# List all releases
gh release list --repo QNXcraft/BGShellBB10

# View specific release
gh release view TAG_NAME --repo QNXcraft/BGShellBB10
```

## What's Included in Each Release

Each release automatically includes:

1. **Source Archive**: `BGShellBB10-VERSION-source.zip`
   - All source code
   - Build files
   - Documentation
   - Assets

2. **Release Notes**: Auto-generated with:
   - Version information
   - Installation instructions
   - Feature list
   - Links to documentation

3. **BAR Package** (if BB10 NDK is configured):
   - `BGShellBB10-VERSION.bar`
   - Ready to install on BB10 devices

## Current Status

✅ **What's Working:**
- Workflows are configured and pushed to GitHub
- Release workflow triggers on tags matching: `v*.*.*`, `[0-9]+.[0-9]+.[0-9]+`, `release-*`
- Source archives are created automatically
- Release notes are generated
- Manual workflow dispatch works

⚠️ **What Needs Setup:**
- BB10 NDK environment (for building BAR files)
  - See BUILD_SETUP.md for options
  - Currently only source archives are created

## Troubleshooting

### Release workflow didn't trigger after creating tag

**Issue:** Tag name doesn't match the expected pattern

**Solution:** Use one of these formats:
- `v0.0.1` (recommended)
- `0.0.1`
- `release-0.0.1`

### Release created but no build artifacts

**Issue:** BB10 NDK not configured in GitHub Actions

**Solution:** 
- This is expected for now
- See BUILD_SETUP.md for NDK setup options
- Source archives are still created

### Workflow failed

**Check logs:**
```bash
# Get latest run ID
RUN_ID=$(gh run list --repo QNXcraft/BGShellBB10 --workflow=release.yml --limit 1 --json databaseId --jq '.[0].databaseId')

# View logs
gh run view $RUN_ID --repo QNXcraft/BGShellBB10 --log-failed
```

## Examples

### Create release v0.0.2.1

```bash
# 1. Update _bar-descriptor.xml
#    <versionNumber>0.0.2</versionNumber>
#    <buildId>1</buildId>

# 2. Commit changes
git add _bar-descriptor.xml
git commit -m "Bump version to 0.0.2.1"
git push

# 3. Create and push tag
git tag -a v0.0.2.1 -m "Release v0.0.2.1 - Feature XYZ"
git push origin v0.0.2.1

# 4. Wait ~30 seconds, then check
gh run list --repo QNXcraft/BGShellBB10 --workflow=release.yml --limit 1

# 5. View release
gh release view v0.0.2.1 --repo QNXcraft/BGShellBB10 --web
```

## Links

- Releases: https://github.com/QNXcraft/BGShellBB10/releases
- Actions: https://github.com/QNXcraft/BGShellBB10/actions
- Workflows: https://github.com/QNXcraft/BGShellBB10/tree/master/.github/workflows

## Support

For issues with:
- **Releases/Workflows**: Check workflow logs and this guide
- **Build process**: See BUILD_SETUP.md
- **Application**: Email support@bgmot.com
