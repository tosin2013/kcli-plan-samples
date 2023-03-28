#!/bin/bash

# Display a menu and get the user's choice
echo "Select a demo to build:"
echo "1. e2e-demo"
echo "2. edge-console-demo"
echo "3. hello-microshift-demo"
echo "4. ibaas-demo"
echo "5. ostree-demo"
read -p "Enter choice [1-5]: " choice

# Depending on the user's choice, set the DEMONAME variable
case $choice in
  1)
    DEMONAME="e2e-demo"
    ;;
  2)
    DEMONAME="edge-console-demo"
    ;;
  3)
    DEMONAME="hello-microshift-demo"
    ;;
  4)
    DEMONAME="ibaas-demo"
    ;;
  5)
    DEMONAME="ostree-demo"
    ;;
  *)
    echo "Invalid choice"
    exit 1
esac

# Call the build script with the selected DEMONAME
ls demos/
./scripts/build $DEMONAME
