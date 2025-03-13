# Use Node.js base image
FROM node:14

# Set working directory
WORKDIR /app

# Copy files and install dependencies
COPY package.json package-lock.json ./
RUN npm install
RUN npm install express

# Copy the rest of the files
COPY . .

# Start the application
CMD ["node", "server.js"]

# Expose port 3000
EXPOSE 3000
