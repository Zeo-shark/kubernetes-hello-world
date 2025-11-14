# 🚀 Go Hello World on Kubernetes

Welcome! This project is a simple but complete example of how to build a "Hello, World!" web application in Go, containerize it with Docker/Podman, and deploy it to a local Kubernetes cluster using Minikube.

The goal is to provide a clear, step-by-step guide that covers everything from local development to a final Kubernetes deployment, using [Task](https://taskfile.dev/) for automation.

## 🚀 Quick Start (The Easy Way)

This project is configured to get you up and running with a single command. This is the fastest way to see the application live on your Minikube cluster.

1.  **Start your Minikube cluster:**
    ```sh
    minikube start
    ```

2.  **Deploy everything with one command:**
    This command will build the image, load it into Minikube, apply the Kubernetes manifests, and open the application in your browser.

    > ⚠️ **Important:** The default `minikube` task is configured to use **Podman**. If you use **Docker**, please follow the [Step-by-Step Deployment (The Manual Way)](#️-step-by-step-deployment-the-manual-way) section.

    ```sh
    task minikube
    ```

    You should see output indicating the image is being built, loaded, and then `kubectl` will show the created resources. Finally, your default web browser will open, displaying:
    ```
    Hello, Kubernetes from Go! 🚀
    The current time is: 17:45:00
    ```

3.  **Clean Up Deployed Resources:**
    When you're done, you can remove all the deployed Kubernetes resources with:
    ```sh
    task minikube:delete
    ```

4.  **Stop Minikube Cluster:**
    To free up system resources, you can stop the cluster:
    ```sh
    minikube stop
    ```

## 🛠️ Step-by-Step Deployment (The Manual Way)

Want to understand what's happening under the hood? This section breaks down the `task minikube` command into its individual steps. This is great for learning how the pieces fit together.

### Step 1: Start Minikube 🏁

First, ensure your local Kubernetes cluster is running.

```sh
minikube start
```

### Step 2: Build the Container Image 📦

We need to build our Go application into a container image. The `Dockerfile` is set up to create a small, optimized production image.

```sh
# Using Podman
podman build --target=production -t go-hello-world .

# Or using Docker
docker build --target=production -t go-hello-world .
```

-   `--target=production`: This tells the builder to use the final, lean `production` stage from our multi-stage `Dockerfile`.
-   `-t go-hello-world`: We tag the image with the name `go-hello-world`. This name is important because it's referenced in our Kubernetes `deployment.yaml`.

### Step 3: Load the Image into Minikube 🚚

Minikube runs its own isolated container environment. This means it can't see the images you build locally on your host machine. We need to explicitly load our newly built image into Minikube's context.

```sh
minikube image load go-hello-world
```

### Step 4: Deploy to Kubernetes 🚢

Now it's time to tell Kubernetes to run our application. We do this by applying our manifest files located in the `ops/k8s/` directory.

```sh
kubectl apply -f ops/k8s/
```

This command instructs `kubectl` to read the YAML files and create the resources defined within them: a `Deployment` to manage our app's pods and a `Service` to expose them.

### Step 5: Check the Deployment Status ✅

You can verify that everything was created successfully.

```sh
kubectl get all
```

You should see output similar to this, showing your `Deployment`, `Pods` (2 replicas as defined), and `Service`.

```
NAME                                     READY   STATUS    RESTARTS   AGE
pod/go-hello-deployment-xxxxxxxxxx-abcde   1/1     Running   0          60s
pod/go-hello-deployment-xxxxxxxxxx-fghij   1/1     Running   0          60s

NAME                       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/go-hello-service   NodePort    10.100.101.102           80:31234/TCP   60s
service/kubernetes         ClusterIP   10.96.0.1                443/TCP        10m

NAME                                READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/go-hello-deployment   2/2     2            2           60s

NAME                                           DESIRED   CURRENT   READY   AGE
replicaset.apps/go-hello-deployment-xxxxxxxxxx   2         2         2       60s
```

### Step 6: Access the Application 🌐

Minikube provides a handy command to automatically get the URL for a service and open it for you.

```sh
minikube service go-hello-service
```

This will open your browser and navigate to the application, just like the automated task did!

### Step 7: Clean Up 🧹

To delete the resources you just created, you can use `kubectl delete`.

```sh
kubectl delete -f ops/k8s/
```

## 🧑‍🏫 Kubernetes Concepts Explained

This project uses two core Kubernetes resources:

### 1. Deployment (`ops/k8s/deployment.yaml`)

A **Deployment** is a blueprint that tells Kubernetes *how* to run your application.

-   `replicas: 2`: We ask Kubernetes to run two identical instances (Pods) of our application for availability.
-   `selector`: This is how the Deployment knows which Pods to manage. It looks for Pods with the label `app: go-hello`.
-   `template`: This section defines the Pods themselves.
    -   `metadata.labels`: We apply the `app: go-hello` label here, which matches the selector.
    -   `spec.containers`: Here we define the container to run, specifying the `image` (`go-hello-world`), setting `imagePullPolicy: IfNotPresent` (crucial for using local images), and defining the `containerPort` (8080).

### 2. Service (`ops/k8s/service.yaml`)

A **Service** provides a stable network endpoint (a single IP address and DNS name) to access a group of Pods. Pods can be created and destroyed, but the Service address remains constant.

-   `type: NodePort`: This exposes the service on a static port on each node in the cluster. It's a simple way to get external traffic into your app in a development environment like Minikube.
-   `selector`: This is how the Service finds which Pods to send traffic to. It's configured to look for Pods with the label `app: go-hello`.
-   `ports`:
    -   `port: 80`: The port the service will be available on *inside* the cluster.
    -   `targetPort: 8080`: The port on the Pods that traffic should be forwarded to (our Go app listens on 8080).

## 💻 Local Development Workflow

For local development without Kubernetes, you can use the provided `docker-compose` setup.

-   **Start the environment:**
    ```sh
    task dev
    ```
    This will start the Go application in a container. The source code is mounted as a volume, so changes you make locally will be reflected.

-   **Stop the environment:**
    ```sh
    task dev:down
    ```

-   **Open a shell in the container:**
    ```sh
    task dev:shell
    ```
