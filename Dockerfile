# Stage 1: Dependency Installation
FROM node:20 AS deps
WORKDIR /opt/strapi-app

# Copy package files for dependency installation
COPY package.json yarn.lock* package-lock.json* ./
# Install production dependencies (node_modules for runtime)
# We use 'ci' for clean, reliable installs in CI/CD environments
RUN npm ci --only=production

# Stage 2: Strapi Build
FROM node:20 AS builder
WORKDIR /opt/strapi-app

# Copy all files from the current directory (source code)
COPY . .

# Copy production dependencies from the 'deps' stage
COPY --from=deps /opt/strapi-app/node_modules ./node_modules

# Run the Strapi build command. This command typically generates 
# the admin panel interface in the /build directory.
# Note: Strapi often requires all dependencies (not just production) for the build step.
# If this build fails, you may need to switch Stage 2 to run 'npm install' instead of 
# copying from 'deps', but we start with the most efficient way.
RUN npm run build


# Stage 3: Production Runner
# Use a slimmed-down Node image for the final container to minimize size and attack surface
FROM node:20-slim AS runner
WORKDIR /opt/strapi-app

# Copy the core code (excluding node_modules)
COPY --from=builder /opt/strapi-app/ .

# Copy only the necessary node_modules (production ones)
COPY --from=deps /opt/strapi-app/node_modules ./node_modules

# Copy the compiled admin build directory
COPY --from=builder /opt/strapi-app/build ./build

# Set the environment variable for production (critical for Strapi)
ENV NODE_ENV production

# Strapi typically runs on port 1337 by default
ENV PORT 1337
EXPOSE 1337

# Command to start Strapi in production mode
CMD ["npm", "run", "start"]