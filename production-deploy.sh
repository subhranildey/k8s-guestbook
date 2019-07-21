#!/bin/bash

#The following Mandatory Command is required for all deployments for nginx-ingress-controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml

#GCE-GKE
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud-generic.yaml

kubectl apply -f guestbook/all-in-one/production-namespace.yaml
kubectl apply -f guestbook/all-in-one/guestbook-all-in-one.yaml --namespace=production
kubectl apply -f guestbook/all-in-one/production-ingress.yaml
