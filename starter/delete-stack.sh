#!/bin/bash

function print_help {
  echo "Usage: $0 [all|network|web]"
  echo "all: Delete both stacks sequentially (web_stack, then network_stack)"
  echo "web  : Delete only web_stack"
  echo "network  : Delete network_stack, but only if web_stack has been deleted"
  exit 1
}

# Kiểm tra số lượng tham số đầu vào
if [ "$#" -ne 1 ]; then
  print_help
fi

network_stack="udagram-network"
web_stack="udacity-web"

function check_stack_status() {
  local stack_name=$1
  status=$(aws cloudformation describe-stacks --stack-name "$stack_name" --query "Stacks[0].StackStatus" --output text 2>/dev/null)

  if [ "$status" == "DELETE_COMPLETE" ]; then
    echo "$stack_name has already been deleted."
    return 1
  elif [ -z "$status" ]; then
    echo "$stack_name does not exist."
    return 1
  else
    echo "$stack_name is in status: $status"
    return 0
  fi
}

function delete_stack() {
  local stack_name=$1
  echo "Deleting $stack_name..."
  aws cloudformation delete-stack --stack-name "$stack_name"
  aws cloudformation wait stack-delete-complete --stack-name "$stack_name"
  if [ $? -eq 0 ]; then
    echo "$stack_name deleted successfully."
  else
    echo "Failed to delete $stack_name."
  fi
}

case "$1" in
  all)
    check_stack_status "$web_stack"
    if [ $? -eq 0 ]; then
      delete_stack "$web_stack"
    fi
    check_stack_status "$network_stack"
    if [ $? -eq 0 ]; then
      delete_stack "$network_stack"
    fi
    ;;

  web)
    check_stack_status "$web_stack"
    if [ $? -eq 0 ]; then
      delete_stack "$web_stack"
    fi
    ;;

  network)
    check_stack_status "$web_stack"
    if [ $? -eq 0 ]; then
      echo "Error: You must delete $web_stack before deleting $network_stack."
      exit 1
    else
      check_stack_status "$network_stack"
      if [ $? -eq 0 ]; then
        delete_stack "$network_stack"
      fi
    fi
    ;;

  *)
    print_help
    ;;
esac
