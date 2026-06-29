# Readiness & liveness probes

The goal of this lab to quickly figure out how `readienssProbe` and `livenessProbe` works in k8s.

This labs uses the exec command so you don't have to create some REST API with `/health`
route to see how it works.

First create both the `probe-demo.yaml` & `probe-demo-svc.yaml` resource:

```bash
k create -f probe-demo.yaml
```

Then after that run:

```bash
k get pod -w
```

At first you will see something like this:

```txt
probe-demo-xxxxx   0/1   Running
```

And after 15 seconds:

```txt
probe-demo-xxxxx   1/1   Running
```

WHY?
Container is alive immediately.
But readiness only passes after /tmp/ready exists.

If you look at the `probe-demo.yaml` file you will see that the `/tmp/ready` gets created after 15s:

```yaml
command:
  - sh
  - -c
  - |
    mkdir -p /www
    echo "hello from probe-demo" > /www/index.html

    # liveness becomes OK immediately
    touch /tmp/live

    # readiness becomes OK after 15 sec
    sleep 15 # <-- here 🙂️
    touch /tmp/ready

    httpd -f -p 8080 -h /www
```

So During the first 15s:

`livenessProbe` = passing
`readinessProbe` = failing

## Check the service endpoints

```bash
k get endpoints probe-demo-svc -w
```

Or just use `ep` instead of `endpoints`

Before readiness passes, endpoints should be empty or missing addresses.
After readiness passes, you should see the Pod IP added.

## Test traffic through service

```bash
k run curl --image=curlimages/curl -it --rm --restart=Never -- curl probe-demo-svc
```

You should get:

```
hello from probe-demo
```

## Test readiness failure

```bash
POD=$(k get pod -l app=probe-demo -o name)
k exec $POD -- rm /tmp/ready
```

Now check:

```bash
k get pod
```

You should see:

```
0/1   Running
```

And if you check the endpoint `k get pod endpoints probe-demo-svc` you won't see any endpoints.

You can make it ready again:

```bash
POD=$(k get pod -l app=probe-demo -o name)
k exec $POD -- touch /tmp/ready
```

You should see:

```
1/1 Running
```

## Test liveness failure

Liveness is a bit different.

If you remove the `/tmp/live` file:

```bash
POD=$(k get pod -l app=probe-demo -o name)
k exec $POD -- rm /tmp/live
```

Wait a few seconds, then run:

```bash
k get pod
```

You should see the restart count increase:

```
NAME                         READY   STATUS    RESTARTS
probe-demo-xxxxx             1/1     Running   1
```

After restart, the container runs this again:

```
touch /tmp/live
sleep 15
touch /tmp/ready
httpd -f -p 8080 -h /www
```
