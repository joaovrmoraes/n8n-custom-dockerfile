#!/bin/bash

# Script para fazer rebuild e push da imagem Docker para GitHub Packages

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Carregar arquivo .env
if [ -f ".env" ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo -e "${RED}❌ Erro: Arquivo .env não encontrado${NC}"
    echo "Crie o arquivo .env baseado em .env.example"
    exit 1
fi

# Configurações
GITHUB_USERNAME="${GITHUB_USERNAME}"
GITHUB_TOKEN="${GITHUB_TOKEN}"
REGISTRY="${REGISTRY:-ghcr.io}"
IMAGE_NAME="${IMAGE_NAME}"
TAG="${1:-latest}"

# Validações
if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}❌ Erro: GITHUB_TOKEN não está definido no .env${NC}"
    exit 1
fi

if [ -z "$GITHUB_USERNAME" ]; then
    echo -e "${RED}❌ Erro: GITHUB_USERNAME não está definido no .env${NC}"
    exit 1
fi

if [ -z "$IMAGE_NAME" ]; then
    echo -e "${RED}❌ Erro: IMAGE_NAME não está definido no .env${NC}"
    exit 1
fi

echo -e "${YELLOW}🔧 Iniciando processo de build e push...${NC}\n"

# Login no Docker
echo -e "${YELLOW}📝 Fazendo login no GitHub Packages...${NC}"
echo "$GITHUB_TOKEN" | docker login $REGISTRY -u $GITHUB_USERNAME --password-stdin
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Falha ao fazer login${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Login realizado com sucesso${NC}\n"

# Build da imagem
IMAGE_URL="$REGISTRY/$GITHUB_USERNAME/$IMAGE_NAME:$TAG"
echo -e "${YELLOW}🏗️  Fazendo build da imagem: $IMAGE_URL${NC}"
docker build -t "$IMAGE_URL" .
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Falha ao fazer build${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Build concluído${NC}\n"

# Push da imagem
echo -e "${YELLOW}📤 Fazendo push da imagem...${NC}"
docker push "$IMAGE_URL"
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Falha ao fazer push${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Push concluído com sucesso${NC}\n"

# Logout (opcional mas recomendado)
docker logout $REGISTRY
echo -e "${GREEN}✅ Logout realizado${NC}"
echo -e "${GREEN}🎉 Processo finalizado! Imagem disponível em: $IMAGE_URL${NC}"
