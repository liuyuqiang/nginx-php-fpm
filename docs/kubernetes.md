## Kubernetes Guide


### Configure the application

Create ```example-namespace.yml``` file:

```
apiVersion: v1
kind: Namespace
metadata:
  name: example
```

Now create the namespace in kubernetes:

```kubectl create -f example-namespace.yml```

Create ```example-app.yml``` file:

```
apiVersion: v1
kind: ReplicationController
metadata:
  namespace: example
  name: example-app
  labels:
    example-component: example-app
spec:
  replicas: 1
  selector:
    example-component: example-app
  template:
    metadata:
      labels:
        example-component: example-app
    spec:
      containers:
      - name: example-app
        image: liuyuqiang/nginx-php-fpm:latest
        imagePullPolicy: Always
        env:
          - name: ENABLE_XDEBUG
            value: '1'
        ports:
        - containerPort: 80
```

Now run:

```kubectl create -f example-app.yml```

### Using the application

Your container should now be up and running and you can see its details with the following commands:

```
kubectl get pods --namespace example

# make a note of the pod namespace

kubectl describe pod <pod_name> --namespace example
```

### Create a Service for the application

To help expose the application to the outside world you may want to create a service. The example below isn't the only way to do this as it depends on the exact setup of the kubernetes system you have, for example you may want to use an ELB on AWS or you may be on GKE and use googles http load balancer.

Create the file ```example-service.yml``` with the following content:

```
apiVersion: v1
kind: Service
metadata:
  namespace: example
  name: example-app
spec:
  type: ClusterIP
  ports:
    - protocol: TCP
      name: http
      port: 80
      targetPort: 80
  selector:
    app: example-app
```
Now run:
```
kubectl create -f example-service.yml
```

This will create you a service load balancer and allow you to scale your replication controller in the background underneath a unifying IP address. You can get the details by running:
```
kubectl describe service example-app --namespace example
```

### Running commands in the container/pod

If you want to push or pull code to the container you can run the following commands:
```
kubectl get pods --namespace example

# make a note of the pod namespace

# update code in the container
kubectl exec -t <pod_name> /usr/bin/pull --namespace example
# push code back to github
kubectl exec -t <pod_name> /usr/bin/push --namespace example
```
If you want to drop into the shell run the following:
```
kubectl exec -it <pod_name> bash --namespace example
```

### Scale your app
You can scale the replication controller with the following command:
```
kubectl scale --replicas=3 rc/example-app --namespace example
```
