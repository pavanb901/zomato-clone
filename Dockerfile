# ---- Build Stage ----
FROM node:18-alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first (leverage Docker cache)
COPY package*.json ./

# Install all dependencies (including devDependencies needed for build)
RUN npm ci

# Copy the rest of the application source code
COPY . .

# Build the React app (NODE_OPTIONS needed for Node 17+ / OpenSSL compatibility)
RUN NODE_OPTIONS=--openssl-legacy-provider npm run build

# ---- Production Stage ----
FROM node:18-alpine

# Install 'serve' to serve the static build
RUN npm install -g serve

# Set the working directory
WORKDIR /app

# Copy only the build output from the builder stage
COPY --from=builder /app/build ./build

# Expose port 3000
EXPOSE 3000

# Serve the built React app as static files
CMD ["serve", "-s", "build", "-l", "3000"]
