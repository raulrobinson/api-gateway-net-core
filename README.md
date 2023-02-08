# api-gateway-net-core
API Gateway with Ocelot Routing

#### Dockerfile
```text
# First Stage SDK Framework.
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /app

EXPOSE 443
EXPOSE 80

# Generate SSL Certificate trust signed.
RUN dotnet dev-certs https -ep %USERPROFILE%\.aspnet\https\api-gateway.pfx -p Pass@*****
RUN dotnet dev-certs https --trust

# copy project csproj file and restore it in docker directory
COPY . .
RUN dotnet restore

# Copy everything into the docker directory and build
COPY . .
RUN dotnet publish -c Release -o out

# Build runtime final image
FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app
COPY --from=build /app/out .
ENTRYPOINT ["dotnet", "api-gateway.dll"]
```

#### Docker Build image
- docker build . -t api-gateway:v1

#### Docker Run Container
- docker run -p 5000:443 -e ASPNETCORE_URLS="https://+;" -e ASPNETCORE_HTTPS_PORT=7001 -e ASPNETCORE_Kestrel__Certi
ficates__Default__Password="Pass@*****" -e ASPNETCORE_Kestrel__Certificates__Default__Path=/https/api-gateway.pfx -v %USERPROFILE%\.aspnet\https:/https/ a
pi-gateway:v3

```text
docker run -p 5000:443 
-e ASPNETCORE_URLS="https://+;" 
-e ASPNETCORE_HTTPS_PORT=7001 
-e ASPNETCORE_Kestrel__Certificates__Default__Password="Pass@*****" 
-e ASPNETCORE_Kestrel__Certificates__Default__Path=/https/api-gateway.pfx 
-v %USERPROFILE%\.aspnet\https:/https/ 
api-gateway:v3
```
