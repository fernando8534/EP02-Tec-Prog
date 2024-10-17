#!/bin/bash
##################################################################
# MAC0216 - Técnicas de Programação I (2024)
# EP2 - Programação em Bash
#
# Nome do(a) aluno(a) 1: Fernando Ramos Takara
# NUSP 1: 13782230
#
# Nome do(a) aluno(a) 2:
# NUSP 2:
##################################################################

echo "+++++++++++++++++++++++++++++++++++++++
Este programa mostra estatísticas do
Serviço 156 da Prefeitura de São Paulo
+++++++++++++++++++++++++++++++++++++++"

#Se o número de parâmetros for diferente de 0, então baixamos os n URL's com o wget no path_atual/Dados. Além disso, modificamos a codificação do arquivo csv baixado de ISO-8859-1 para UTF+8 com o iconv, deletando o antigo.
if [ $# != 0 ]; then
    for i in $#; do 
        dir_atual=$(pwd)
        dir_dados="/Dados"
        wget -nv ${!i} -P "$dir_atual$dir_dados"
        novo_arq=$(ls "$dir_atual$dir_dados" | head -n 1 | tr -d '\n')
        iconv -f ISO-8859-1 -t UTF8 "$dir_atual$dir_dados"/"$novo_arq" -o "$dir_atual$dir_dados"/temp.csv
        rm "$dir_atual$dir_dados"/"$novo_arq"
        mv "$dir_atual$dir_dados"/temp.csv "$dir_atual$dir_dados"/"$novo_arq"
    done
fi

exit 0
