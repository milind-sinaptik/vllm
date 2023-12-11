#!/bin/bash

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
  source activate llmcd
  pkill -f "python -m vllm.entrypoints.api_server"
  pip install -e .
  echo -e "$HUGGING_FACE_TOKEN\nn" | huggingface-cli login
  timestamp=$(date "+%Y%m%d%H%M%S")
  python -m vllm.entrypoints.api_server --model="$LLM_NAME" --trust-remote-code > "std_$timestamp.out" 2>&1 &
EOF

echo "Deployment to $DEPLOY_ENVIRONMENT completed successfully."
