FROM n8nio/n8n:2.2.3
USER root
RUN npm install -g fft-js math html-to-pdf
USER node