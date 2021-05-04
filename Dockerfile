FROM mcr.microsoft.com/dotnet/sdk:5.0-focal AS devbase

FROM devbase AS build
RUN curl -sL https://deb.nodesource.com/setup_16.x |  bash -
RUN apt-get install -y nodejs

ARG publishProject="reactenvruntime.app"
ARG OKTA_DOMAIN
#ARG REACT_APP_OKTA_CLIENT_ID
#ARG REACT_APP_PROVISIONING_MANAGER_API_BASE_URL
#ARG REACT_APP_OKTA_ISSUER
#ARG REACT_APP_MYHEALTHWISE_API_BASE_URL
#ARG REACT_APP_INSTRUMENTATION_KEY
#ARG REACT_APP_CLOUD_ROLE
#ARG REACT_APP_ENVIRONMENT
ARG COMMIT_HASH="1"
ARG BUILD_NUMBER="2"
ARG BUILD_ID="3"

WORKDIR /src
COPY . .
RUN echo "*** Adding .buildinfo ${publishProject} ***" && \
    echo "${COMMIT_HASH}\n${BUILD_NUMBER}\n${BUILD_ID}" > ${publishProject}/.buildinfo
RUN echo "*** Building ${publishProject} ***" && \
    dotnet build ${publishProject}/${publishProject}.csproj --nologo --configuration 'Release' --output /app/build
#RUN echo "*** Running unit tests ***" && \
    #for testproj in *unit.tests/*unit.tests.csproj; do \
    #dotnet test $testproj --nologo --configuration 'Release' --logger="trx;LogFileName=$testproj.trx" --results-directory="TestResults" --output /app/test; \
    #done
#RUN echo "*** Running integration tests ***" && \
    #for testproj in *integration.tests/*integration.tests.csproj; do \
    #dotnet test $testproj --nologo --configuration 'Release' --logger="trx;LogFileName=$testproj.trx" --results-directory="TestResults" --output /app/test; \
    #done
RUN echo "*** Publishing ${publishProject} ***" && \
    dotnet publish ${publishProject}/${publishProject}.csproj --nologo --configuration 'Release' --output /app/publish
#RUN npm run test:ci --prefix ${publishProject}/ClientApp --if-present

FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS final
RUN curl -sL https://deb.nodesource.com/setup_16.x |  bash -
RUN apt-get update
RUN apt-get install -y nodejs
RUN apt-get install -y npm
WORKDIR /app
#COPY --from=build ["/src/TestResults", "/testresults"]
RUN npm i @beam-australia/react-env
COPY --from=build ["/app/publish", ""]
EXPOSE 80
# ENTRYPOINT ["npx", "react-env", "--path ClientApp/.env", "--dest ClientApp/build", "--"]
# ENTRYPOINT ["npx", "react-env --path ClientApp/.env --dest ClientApp/build"]
ENTRYPOINT exec npx react-env --path ClientApp/.env.template --dest ClientApp/build -- dotnet reactenvruntime.app.dll
# ENTRYPOINT ["dotnet", "reactenvruntime.app.dll"]
# CMD ["dotnet", "reactenvruntime.app.dll"]