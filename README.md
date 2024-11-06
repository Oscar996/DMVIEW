# DMVIEW
Script de instalação do DMView no Rocky Linux 8

Efetua o download dos pacotes, extrai, instala e configura bancos, e instala a aplicação.
Senha definida para o Oracle DB:

```
9Xk7V9YX
```
Realizar a substituição da senha em ambientes de produção.

Executar como usuário root:

Copiar e colar no terminal

```bash
curl -LJO https://raw.githubusercontent.com/Oscar996/DMVIEW/main/Instalacao%20DMView.sh && chmod +x Instalacao%20DMView.sh && time ./Instalacao%20DMView.sh
```

Tempo de instalação aproximado:
```
real    37m41,810s
user    5m13,359s
sys     0m30,506s
```
