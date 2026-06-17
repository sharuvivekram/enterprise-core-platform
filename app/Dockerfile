# Step 1: Use an official, ultra-lightweight minimal Python image
FROM python:3.9-slim

# Step 2: Set the working directory inside the container
WORKDIR /app

# Step 3: Copy only requirements first to leverage Docker layer caching
COPY requirements.txt .

# Step 4: Install dependencies cleanly without saving package caches
RUN pip install --no-cache-dir -r requirements.txt

# Step 5: Copy the application source code
COPY app.py .

# Step 6: Expose the port our app runs on
EXPOSE 8000

# Step 7: Define the execution command
CMD ["python", "app.py"]