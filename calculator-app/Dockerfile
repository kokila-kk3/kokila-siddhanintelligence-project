# --------------------
# 1. BUILD STAGE
# --------------------
FROM node:20 AS build

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build


# --------------------
# 2. PRODUCTION STAGE
# --------------------
FROM node:20-alpine

WORKDIR /app

# install only production static server
RUN npm install -g serve

# copy ONLY build output
COPY --from=build /app/dist ./dist

EXPOSE 3000

CMD ["serve", "-s", "dist", "-l", "3000"]
