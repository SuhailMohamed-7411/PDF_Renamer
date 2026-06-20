#!/bin/bash

# Exit script if any command fails
set -e

echo "=================================================="
echo "  GitHub Repository Setup: AEP PDF Renamer"
echo "=================================================="

# 1. Initialize the git repository if not already initialized
if [ ! -d ".git" ]; then
    echo "Initializing new Git repository..."
    git init
else
    echo "Git repository already exists. Skipping initialization."
fi

# 2. Add files to staging
echo "Staging README.md and Javascript files..."
git add README.md
# Adds any .js files in the directory (assuming you saved the code as renameAEPFiles.js)
git add *.js 

# 3. Commit the changes
echo "Committing files..."
git commit -m "Initial commit: Add AEP PDF Renamer Google Apps Script and Readme"

# 4. Ask user for their GitHub repository URL
echo ""
read -p "Please enter your remote GitHub repository URL (e.g., https://github.com/username/repo.git): " repo_url

# 5. Connect to remote and push
echo "Setting branch to 'main' and configuring remote..."
git branch -M main

# Check if origin already exists, if so, set the new URL, otherwise add it
if git remote | grep origin > /dev/null; then
    git remote set-url origin "$repo_url"
else
    git remote add origin "$repo_url"
fi

echo "Pushing code to GitHub..."
git push -u origin main

echo "=================================================="
echo "  Success! Code has been pushed to GitHub."
echo "=================================================="
