FROM n8nio/n8n:latest
USER root
RUN npm install -G fftjs math
USER node