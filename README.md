# Install Guestbook 

This script will let you setup guestbook application in no time,  It has been designed to be as unobtrusive and universal as possible. 

## Installation
Run the script and follow the assistant:

`curl -O https://raw.githubusercontent.com/subhranildey/k8s-guestbook/master/deploy-guestbook.sh && sh deploy-guestbook.sh  && rm -rf deploy-guestbook.sh`

## Loadtest 

Load test is not part of the deployment script, run this to test the application. 

`kubectl apply -f https://raw.githubusercontent.com/subhranildey/k8s-guestbook/master/loadtest.yaml --namespace=<ENV>`

### To check the load on pods every second

 `watch -n 1 kubectl top pods -n <ENV>`

 ### To Check the HPA 

 `watch -n 1  kubectl get hpa - <ENV>`

 ### To check the autoscaling of the pods

 `watch -n 1 kubectl get hpa -n production`


