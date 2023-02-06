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