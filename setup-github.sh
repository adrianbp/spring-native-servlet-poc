#!/bin/bash

# GitHub Repository Setup Script for Spring Native POC
# Uses GitHub CLI with Copilot authentication

echo "🚀 Spring Native POC - GitHub Repository Setup"
echo "=============================================="
echo

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    echo "Installing GitHub CLI..."
    
    # Install GitHub CLI for Ubuntu/Debian
    if command -v apt &> /dev/null; then
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install gh -y
    else
        echo "Please install GitHub CLI manually: https://cli.github.com/"
        exit 1
    fi
fi

# Check authentication status
echo "🔐 Checking GitHub authentication..."
if ! gh auth status &> /dev/null; then
    echo "Please login to GitHub CLI:"
    echo "You can use 'gh auth login' or authenticate via web browser"
    gh auth login --web
fi

echo "✅ GitHub CLI is authenticated"
echo

# Get repository name
read -p "📝 Repository name (default: spring-native-poc): " REPO_NAME
REPO_NAME=${REPO_NAME:-spring-native-poc}

# Get description
read -p "📝 Repository description (press Enter for default): " REPO_DESC
REPO_DESC=${REPO_DESC:-"Spring Native POC with Hexagonal Architecture - Performance comparison between Native and JAR deployments"}

# Ask if public repository
read -p "🌐 Make repository public? (y/n, default: y): " IS_PUBLIC
IS_PUBLIC=${IS_PUBLIC:-y}

if [[ $IS_PUBLIC == "y" || $IS_PUBLIC == "Y" ]]; then
    VISIBILITY="--public"
else
    VISIBILITY="--private"
fi

# Create the repository
echo
echo "🏗️  Creating GitHub repository '$REPO_NAME'..."
gh repo create $REPO_NAME --description "$REPO_DESC" $VISIBILITY --clone=false

if [ $? -ne 0 ]; then
    echo "❌ Failed to create repository. Please check if the repository name is available."
    exit 1
fi

echo "✅ Repository created successfully!"
echo

# Get GitHub username
GITHUB_USERNAME=$(gh api user --jq '.login')
echo "📋 GitHub Username: $GITHUB_USERNAME"

# Initialize git repository if not already initialized
if [ ! -d ".git" ]; then
    echo "🔧 Initializing git repository..."
    git init
    git branch -M main
fi

# Add remote origin
git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git

echo "🔧 Adding files to git..."
git add .
git commit -m "Initial commit: Spring Native POC with Hexagonal Architecture

Features:
- Hexagonal architecture with Domain/Infrastructure layers
- User management REST API with CRUD operations  
- Spring Boot 3.4.9 with Java 17
- GraalVM native compilation support
- H2 in-memory database with JPA
- Docker configurations for JAR and Native builds
- GitHub Actions CI/CD workflows
- Kubernetes deployment manifests
- AWS EKS infrastructure with Terraform
- Prometheus + Grafana monitoring setup
- Performance comparison dashboards

Architecture:
- Clean separation of concerns
- Ports and adapters pattern
- Domain-driven design principles
- Infrastructure independence"

echo "🚀 Pushing to GitHub..."
git push -u origin main

if [ $? -eq 0 ]; then
    echo "✅ Code successfully pushed to GitHub!"
    echo "🌐 Repository URL: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
else
    echo "❌ Failed to push to GitHub"
    exit 1
fi

echo
echo "🎉 GitHub repository setup completed!"
echo "=================================="
echo "Repository: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo "Workflows will automatically run on push and pull requests"
echo

# Optional: Open repository in browser
read -p "🌐 Open repository in browser? (y/n): " OPEN_BROWSER
if [[ $OPEN_BROWSER == "y" || $OPEN_BROWSER == "Y" ]]; then
    gh repo view --web
fi

echo
echo "📚 Next Steps:"
echo "1. ✅ Repository created and code pushed"
echo "2. 🔍 Check GitHub Actions workflows in the Actions tab"
echo "3. 🔐 Set up AWS credentials for EKS deployment (optional)"
echo "4. 🐳 Run 'docker-compose up --build' for local testing"
echo "5. 📖 Review the README.md for detailed instructions"
echo
echo "🚀 Ready to test your Spring Native POC!"

# Optional: Open repository in browser
read -p "🌐 Open repository in browser? (y/n): " OPEN_BROWSER
if [[ $OPEN_BROWSER == "y" || $OPEN_BROWSER == "Y" ]]; then
    gh repo view --web
fi

echo
echo "� Next Steps:"
echo "1. Check GitHub Actions workflows in the Actions tab"
echo "2. Set up AWS credentials if you want to deploy to EKS"
echo "3. Run 'docker-compose up --build' for local testing"
echo "4. Review the README.md for detailed instructions"
echo "3. Default Grafana credentials: admin/admin123"
echo

echo "🎉 Setup Complete!"
echo "=================="
echo "Repository URL: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo "Next steps:"
echo "1. Configure AWS secrets in GitHub"
echo "2. Create EKS cluster using Terraform"
echo "3. Push changes to trigger CI/CD pipelines"
echo "4. Monitor performance differences in Grafana"
