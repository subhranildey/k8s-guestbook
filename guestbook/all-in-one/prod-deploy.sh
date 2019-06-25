#!/bin/bash

kubectl apply -f prod-namespace.yaml
kubectl apply -f guestbook-all-in-one.yaml --namespace=production
