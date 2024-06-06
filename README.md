# Cardápio Digital iOS

Este é um exemplo de uma aplicação iOS para um cardápio digital, que permite aos usuários visualizar uma lista de alimentos disponíveis e adicionar novos alimentos ao cardápio.

## Funcionalidades

- Visualizar alimentos disponíveis no cardápio.
- Adicionar novos alimentos ao cardápio.
- Atualização da lista de produtos ao fazer scroll para cima no topo da tela.

## Repositórios complementares

- [Repositório do backend Spring](https://github.com/luizgolima/fiap-cardapio-digital-server)
- [Repositório do cliente web](https://github.com/luizgolima/fiap-cardapio-digital-client)

## Aplicações no ar (deploy)
- [Frontend](https://fiap-cardapio-digital-client.onrender.com)
- [Backend](https://fiap-cardapio-digital-server.onrender.com/food)

## Requisitos

- Xcode 15
- Swift 5
- iOS 17

## Instalação e Execução Local

1. Clone este repositório:
   ```bash
   git clone https://github.com/luizgolima/fiap-cardapio-digital-ios.git
   ```
2. Abra o projeto no Xcode.
3. Execute o aplicativo no simulador iOS ou em um dispositivo físico.

Obs.: Certifique-se de que o servidor Spring backend esteja em execução (local ou em deploy). Se estiver rodando o backend localmente, lembre-se de atualizar a URL da chamada da API do cliente para `http://localhost:8080/food`.

