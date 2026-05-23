FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY ChallengeNET-main/ClyvoCare.API.csproj ./
RUN dotnet restore ClyvoCare.API.csproj

COPY ChallengeNET-main/ ./
RUN dotnet publish ClyvoCare.API.csproj -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:10.0
RUN groupadd --system appgroup && useradd --system --gid appgroup --home /app appuser
WORKDIR /app

COPY --from=build /app/publish .
RUN chown -R appuser:appgroup /app

USER appuser
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

ENTRYPOINT ["dotnet", "ClyvoCare.API.dll"]
