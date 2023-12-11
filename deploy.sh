#!/bin/bash

# Script to deploy a web application to EC2

# Check if required environment variables are set
if [ -z "$LLM_NAME" ]; then
  echo "Error: LLM_NAME not set."
  exit 1
fi

# Set variables
REMOTE_DIR="/root/vllm"

# SSH into the EC2 instance and pull the latest code
ssh -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST <<EOF
  cd $REMOTE_DIR
  git fetch origin main
  git reset --hard origin/main
EOF

# Execute deployment commands
ssh -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST <<EOF
  cd $REMOTE_DIR
  source acivate llmcd
  pip install -e .
  python -m vllm.entrypoints.api_server --model="$LLM_NAME" --trust-remote-code
EOF

echo "Deployment to $DEPLOY_ENVIRONMENT completed successfully."
