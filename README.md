# api-gateway-net-core
API Gateway with Ocelot Routing

#### Dockerfile
```text
# ---------------------------------------------------
#	DOCKERFILE HTTPS ASP.NET Core
# ---------------------------------------------------
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

# ---------------------------------------------------
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["OcelotGateway/OcelotGateway.csproj", "OcelotGateway/"]
RUN dotnet restore "OcelotGateway/OcelotGateway.csproj"

COPY . .
WORKDIR "/src/OcelotGateway"
RUN dotnet build "OcelotGateway.csproj" -c Release -o /app/build

COPY csr.conf /app/build
COPY cert.conf /app/build

# ---------------------------------------------------
FROM build AS publish
RUN dotnet publish "OcelotGateway.csproj" -c Release -o /app/publish /p:UseAppHost=false

RUN openssl genrsa -out /app/publish/server.key 2048
RUN openssl req -new -key /app/publish/server.key -out /app/publish/server.csr -config /app/build/csr.conf
RUN openssl req -x509 -sha256 -days 356 -nodes -newkey rsa:2048 -subj "/CN=DigiCert SHA2 Extended Validation Server CA/C=CO/L=Bogota/O=DigiCert Inc/OU=www.digicert.com" -keyout /app/publish/rootCA.key -out /app/publish/rootCA.crt
RUN openssl x509 -req -in /app/publish/server.csr -CA /app/publish/rootCA.crt -CAkey /app/publish/rootCA.key -CAcreateserial -out /app/publish/server.crt -days 365 -sha256 -extfile /app/build/cert.conf

RUN cat /app/publish/server.key > /app/publish/server.pem
RUN cat /app/publish/server.crt >> /app/publish/server.pem

RUN openssl pkcs12 -export -out /app/publish/certificate.pfx -inkey /app/publish/server.key -in /app/publish/server.pem -passout pass:Pass@*****

# ---------------------------------------------------
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "OcelotGateway.dll"]
```

#### Docker Build image
- docker build . -t ocelot-gateway

#### Docker Run Container
- docker run -it --name=ocelotgateway -e ASPNETCORE_URLS="https://+;" -e ASPNETCORE_HTTPS_PORT=7001 -e ASPNETCORE_Kestrel__Certificates__Default__Password="Pass@*****" -e ASPNETCORE_Kestrel__Certificates__Default__Path=/app/certificate.pfx -p 5000:443 ocelot-gateway

```text
docker run -it --name=ocelotgateway 
  -e ASPNETCORE_URLS="https://+;" 
  -e ASPNETCORE_HTTPS_PORT=7001 
  -e ASPNETCORE_Kestrel__Certificates__Default__Password="Pass@*****" 
  -e ASPNETCORE_Kestrel__Certificates__Default__Path=/app/certificate.pfx 
  -p 5000:443 ocelot-gateway
```
