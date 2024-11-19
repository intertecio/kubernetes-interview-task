FROM node:lts AS builder

ENV NODE_ENV=production

WORKDIR /usr/src/app
COPY app/package*.json ./
RUN npm ci --only=production

COPY app/ .

# Build runtime image
FROM node:lts-slim

WORKDIR /usr/src/app
COPY --from=builder /usr/src/app /usr/src/app

EXPOSE 3000
CMD ["npm", "start"]
