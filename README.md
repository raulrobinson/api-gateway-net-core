# api-gateway-net-core
API Gateway with Ocelot Routing

#### Docker Build image
- docker build . -t api-gateway:v1

#### Docker Run Container
- docker run -p 5000:443 -e ASPNETCORE_URLS="https://+;" -e ASPNETCORE_HTTPS_PORT=7001 -e ASPNETCORE_Kestrel__Certificates__Default__Password="Pass@*****" -e ASPNETCORE_Kestrel__Certificates__Default__Path=/https/ocelotgateway.pfx -v %USERPROFILE%\.aspnet\https:/https/ api-gateway:v1
