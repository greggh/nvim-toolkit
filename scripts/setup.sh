#!/bin/bash
# Project template setup script
# Customizes the template files for a new project

set -e

echo "Project Setup Script"
echo "===================="
echo

# Get project information
read -p "Project name: " PROJECT_NAME
read -p "Project description: " PROJECT_DESCRIPTION
read -p "GitHub greggh: " GITHUB_USERNAME
read -p "Full name for license: " FULL_NAME
read -p "Email for security contacts: " EMAIL
read -p "Initial version [0.1.0]: " PROJECT_VERSION
PROJECT_VERSION=${PROJECT_VERSION:-0.1.0}
YEAR=$(date +%Y)

# Convert project name for Lua modules (replace hyphens with underscores)
LUA_MODULE_NAME=$(echo "$PROJECT_NAME" | sed 's/-/_/g')

echo
echo "Customizing project files..."

# Update README.md
sed -i "s/Project Template Repository/$PROJECT_NAME/g" README.md
sed -i "s/A comprehensive template repository with best practices for modern GitHub projects\./$PROJECT_DESCRIPTION/g" README.md
# Add version badge to README.md if it doesn't exist
if ! grep -q "Version: v" README.md; then
  sed -i "/# $PROJECT_NAME/a \\\nVersion: v$PROJECT_VERSION" README.md
else
  sed -i "s/Version: v[0-9.]\+/Version: v$PROJECT_VERSION/g" README.md
fi

# Update CHANGELOG.md
sed -i "s/greggh\/project/$GITHUB_USERNAME\/$PROJECT_NAME/g" CHANGELOG.md
# Add comparison links if they don't exist
if ! grep -q "\[Unreleased\]: " CHANGELOG.md; then
  echo >> CHANGELOG.md
  echo "[Unreleased]: https://github.com/$GITHUB_USERNAME/$PROJECT_NAME/compare/v$PROJECT_VERSION...HEAD" >> CHANGELOG.md
  echo "[$PROJECT_VERSION]: https://github.com/$GITHUB_USERNAME/$PROJECT_NAME/releases/tag/v$PROJECT_VERSION" >> CHANGELOG.md
fi

# Update LICENSE
sed -i "s/\[year\]/$YEAR/g" LICENSE
sed -i "s/\[fullname\]/$FULL_NAME/g" LICENSE

# Update CONTRIBUTING.md
sed -i "s/\[maintainer-email\]/$EMAIL/g" CONTRIBUTING.md
sed -i "s/greggh\/project-name/$GITHUB_USERNAME\/$PROJECT_NAME/g" CONTRIBUTING.md

# Update GitHub templates
sed -i "s/greggh\/project-name/$GITHUB_USERNAME\/$PROJECT_NAME/g" .github/ISSUE_TEMPLATE/config.yml
sed -i "s/security@example\.com/$EMAIL/g" SECURITY.md

# Update SUPPORT.md
sed -i "s/greggh\/project-name/$GITHUB_USERNAME\/$PROJECT_NAME/g" SUPPORT.md

# Set up version management
echo "Setting up version management..."
mkdir -p "lua/$LUA_MODULE_NAME"
cp templates/version.lua "lua/$LUA_MODULE_NAME/version.lua"
sed -i "s/0\.1\.0/$PROJECT_VERSION/g" "lua/$LUA_MODULE_NAME/version.lua"

# Set up pre-commit hooks
echo "Setting up git hooks..."
mkdir -p .git/hooks
ln -sf ../../.githooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

echo
echo "Setup complete! Your project is ready to use."
echo
echo "Next steps:"
echo "1. Review and customize the documentation files"
echo "2. Set up your development environment"
echo "3. Start building your project"
echo "4. Run the version check: lua scripts/version_check.lua $LUA_MODULE_NAME"
echo
echo "Happy coding!"