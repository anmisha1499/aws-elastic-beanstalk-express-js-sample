FROM node:16

# Set the application working directory.
WORKDIR /app

# Copy dependency definitions first for better Docker layer caching.
COPY package*.json ./

# Install production dependencies.
RUN npm ci --omit=dev

# Copy the application source code.
COPY app.js ./

# Document the port used by the Express application.
EXPOSE 8080

# Start the application.
CMD ["npm", "start"]
