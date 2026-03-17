FROM node:22-alpine AS dependencies-env
COPY package.json .npmrc* /app/
WORKDIR /app
RUN npm install --omit=dev --legacy-peer-deps

FROM dependencies-env AS build-env
COPY . /app/
WORKDIR /app
RUN npm install --legacy-peer-deps
RUN npm run build

FROM node:22-alpine
COPY package.json .npmrc* /app/
COPY --from=dependencies-env /app/node_modules /app/node_modules
COPY --from=build-env /app/build /app/build
COPY --from=build-env /app/public /app/public
RUN apk add --no-cache curl
WORKDIR /app
# there is a DOMAINS env with comma separated allowed domains for image processing
CMD ["npm", "run", "start"]
