# First Stage SDK Framework.
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /app

EXPOSE 443
EXPOSE 80

# Generate SSL Certificate trust signed.
#RUN dotnet dev-certs https -ep %USERPROFILE%\.aspnet\https\api-gateway.pfx -p Pass@*****
#RUN dotnet dev-certs https --trust

# copy project csproj file and restore it in docker directory
COPY . .
RUN dotnet restore

# Copy everything into the docker directory and build
COPY . .
RUN dotnet publish -c Release -o out

# Build runtime final image
#FROM mcr.microsoft.com/dotnet/aspnet:6.0
#WORKDIR /app
#COPY --from=build /root/.dotnet/corefx/cryptography/x509stores/my/* /root/.dotnet/corefx/cryptography/x509stores/my/
#COPY --from=build /app/out .
#ENTRYPOINT ["dotnet", "api-gateway.dll"]

# -------------------------------------------------------------------------------------------

FROM mcr.microsoft.com/dotnet/aspnet:6.0

# update system
RUN apt-get update -y && apt-get upgrade -y

# dotnet specific env vars, default to development environment
ENV ASPNETCORE_ENVIRONMENT=Development
ENV ASPNETCORE_URLS=http://+:80;https://+:443

# dotnet kestrel env vars
ENV Kestrel:Certificates:Default:Path=/etc/ssl/private/cert.pfx
ENV Kestrel:Certificates:Default:Password=changeit
ENV Kestrel:Certificates:Default:AllowInvalid=true
ENV Kestrel:EndPointDefaults:Protocols=Http1AndHttp2

# copy certificate authority certs from local file system
ARG CA_KEY=C://Users//OPT//.aspnet//https//rootCAKey.pem
ARG CA_CERT=C://Users//OPT//.aspnet//https//rootCACert.pem
ARG DOMAINS='localhost 127.0.0.1 ::1'

# default ca cert location (mkcert)
COPY ${CA_KEY} /root/.local/share/mkcert/rootCAKey.pem
COPY ${CA_CERT} /root/.local/share/mkcert/rootCACert.pem

# install CA and SSL cert
RUN apt-get install curl -y && \
	curl -L https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64 > /usr/local/bin/mkcert && \
	chmod +x /usr/local/bin/mkcert
RUN mkcert -install
RUN mkcert -p12-file /etc/ssl/private/cert.pfx -pkcs12 $DOMAINS

# Install locale
RUN apt-get install locales -y \
	&& localedef -f UTF-8 -i en_GB en_GB.UTF-8 \
	&& update-locale LANG=en_GB.utf8

ENV LANG=en_GB:en \
	LANGUAGE=en_GB:en \
	LC_ALL=en_GB.UTF-8

WORKDIR /app

EXPOSE 80
EXPOSE 443