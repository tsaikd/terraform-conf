* init redis cluster
```
terraform apply
sh ./redis/kubernetes/init.sh test-redis
```

* cleanup
```
kubectl delete statefulset,service,pvc -l app=test-redis
```

* reference
https://github.com/sanderploegsma/redis-cluster
