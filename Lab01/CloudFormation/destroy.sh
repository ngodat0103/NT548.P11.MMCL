#!/bin/bash
#set -x
# Default values
ROOT_STACK_NAME="Lab01"

# Function to prompt the user for input with a default value
prompt() {
  read -p "$1 [$2]: " input
  echo "${input:-$2}"
}

# Prompt user for input
stack_name=$(prompt "Enter CloudFormation stack name to delete" "$ROOT_STACK_NAME")

# Function to check if the stack exists
check_stack_exists() {
  stack_name=$1
  stack_status=$(aws cloudformation describe-stacks --stack-name "$stack_name" --query "Stacks[0].StackStatus" --output text 2>/dev/null)

  if [ -z "$stack_status" ]; then
    echo "Error: Stack $stack_name does not exist."
    exit 1
  fi
}

# Function to delete the stack
delete_stack() {
  stack_name=$1

  echo "Deleting CloudFormation stack: $stack_name"
  aws cloudformation delete-stack --stack-name "$stack_name"

  # Watch the stack deletion progress
  watch_stack_deletion "$stack_name"
}

# Function to watch the stack deletion progress
watch_stack_deletion() {
  stack_name=$1
  while true; do
    # Get the current status of the stack
    stack_status=$(aws cloudformation describe-stacks --stack-name "$stack_name" --query "Stacks[0].StackStatus" --output text 2>/dev/null)

    # If the stack no longer exists, it has been deleted successfully
    if [ -z "$stack_status" ]; then
      echo "Stack $stack_name deleted successfully."
      break
    fi

    # Output the current status
    echo "Current status of $stack_name: $stack_status"

    # Check if the stack deletion is complete or failed
    if [[ "$stack_status" == "DELETE_FAILED" ]]; then
      echo "Stack $stack_name deletion failed."
      exit 1
    fi

    sleep 10
  done
}

# Check if the stack exists
check_stack_exists "$stack_name"

# Delete the stack
delete_stack "$stack_name"

echo "All resources have been successfully deleted!"
