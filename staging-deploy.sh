#!/bin/bash

#The following Mandatory Command is required for all deployments for nginx-ingress-controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml

#GCE-GKE
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud-generic.yaml

kubectl apply -f guestbook/all-in-one/staging-namespace.yaml
kubectl apply -f guestbook/all-in-one/guestbook-all-in-one.yaml --namespace=staging
kubectl apply -f guestbook/all-in-one/staging-ingress.yaml

IP=$(kubectl get ing -n staging | grep staging | awk '{print $3}')

printf "\n Wait for the Staging IP....\n"

until [[ $IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; do
    IP=$(kubectl get ing -n staging | grep staging | awk '{print $3}')
done

printf "\nMake the below entry to /etc/hosts file \n"

printf "\n$IP staging-guestbook.mstakx.io\n"
