# Kotlin + HTTP4K + GraalVM + OpenFaaS Demonstration

> Highly experimental: **NOT FOR PRODUCTION USE** (yet)

This is a demonstration that it is possible to write a simple serverless app
using [Kotlin](https://kotlinlang.org/) and [HTTP4K](https://www.http4k.org/), 
creating a native binary using [GraalVM](https://www.graalvm.org/) and making 
it run on [OpenFaaS](https://www.openfaas.com/) using the incubating 
[of-watchdog](https://github.com/openfaas-incubator/of-watchdog)

The resulting static binary has a size of **6.5MB** and the entire docker image 
has **19.2MB** size in total.

Keep in mind, there are probably lots of things I haven't considered.

## How to run it

1. Install OpenFaaS according to the [documentation](https://docs.openfaas.com/deployment/)
   > Hint: In case you are doing a local test like I did, e.g. in Docker for 
   > Mac, be sure to enable `faasnetes.imagePullPolicy=IfNotPresent`. Otherwise 
   > the functions won't start if they are not pushed to a docker registry.

2. Build the docker image containing the function and the watchdog
   ```sh
   docker build -t http4k_helloworld:0.0.1 .
   ```
   and push it to a registry that is available from your k8s cluster if necessary

3. Deploy the function to OpenFaas
   ```sh
   faas-cli deploy --gateway "$OPENFAAS_URL" --image http4k_helloworld:0.0.1 --name http4k-hello
   ```
   Output:
   ```
   Deployed. 202 Accepted.
   URL: $OPENFAAS_URL/function/http4k-example
   ```
4. Execute the deployed funtion
   ```sh
   curl -i "$OPENFAAS_URL/function/http4k-hello"
   ```
   Output:
   ```
   HTTP/1.1 200 OK
   Content-Length: 11
   Content-Type: text/plain; charset=utf-8
   Date: Fri, 26 Jul 2019 23:45:58 GMT
   Server: Apache-HttpCore/1.1
   X-Call-Id: ef81808e-3e30-4e9a-ae3c-664e3c54e269
   X-Duration-Seconds: 0.003135
   X-Start-Time: 1564184758245497900

   Hello World%
   ```
